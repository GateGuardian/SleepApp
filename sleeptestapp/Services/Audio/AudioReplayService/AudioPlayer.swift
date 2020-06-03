//
//  AudioPlayer.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import AVFoundation
import RxRelay

public class AudioPlayer: AudioReplayService {
    
    public var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    var audioEngine: AVAudioEngine
    var playerNode: AVAudioPlayerNode
    var audioBuffer: AVAudioPCMBuffer!
    
    public init(audioEngine: AVAudioEngine, fileUrl: URL) {
        self.audioEngine = audioEngine
        self.playerNode = AVAudioPlayerNode()
        setupPlayerNode(fileUrl: fileUrl)
        notificationSubscription()
    }
    
    private func setupPlayerNode(fileUrl: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: fileUrl)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            guard
                let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            else {
                throw AudioReplayServiceError.failedToCreateAudioBuffer
            }
            self.audioBuffer = audioFileBuffer
            try audioFile.read(into: audioFileBuffer)
            
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFileBuffer.format)
        } catch let error {
            fatalError("Failed to create and connect player for file: \(fileUrl.absoluteString), error: \(error)")
        }
    }
    
    public func start() {
        switch state.value {
        case .stopped:
            executeStart()
        default:
            return
        }
    }
    
    public func setVolume(_ volume: Float) {
        playerNode.volume = volume
    }
    
    public func pause() {
        guard state.value == .performing && playerNode.engine != nil else { return }
        playerNode.pause()
        state.accept(.paused)
    }
    
    public func resume() {
        guard (state.value == .paused || state.value == .systemPaused) && playerNode.engine != nil else { return }
        try? audioEngine.start()
        playerNode.play()
        state.accept(.performing)
    }
    
    public func stop() {
        guard state.value != .stopped && playerNode.engine != nil else { return }
        print("Player Stop")
        playerNode.stop()
        state.accept(.stopped)
    }
    
    public func reset() {
        stop()
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        playerNode.volume = 1.0
    }
    
    //MARK: - Private
    
    private func executeStart() {
        do {
            playerNode.scheduleBuffer(audioBuffer, at: nil, options:AVAudioPlayerNodeBufferOptions.loops)
            try audioEngine.start()
            playerNode.play()
            state.accept(.performing)
        } catch let error {
            state.accept(.error(error))
        }
    }
    
    private func notificationSubscription() {
         NotificationCenter.default.addObserver(self, selector: #selector(handleSessionInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleSessionInterruption(notification: Notification) {
        guard
            let info = notification.userInfo,
            let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return }
        switch type {
        case .began:
            guard state.value == .performing else { return }
            audioEngine.pause()
            try? AVAudioSession.sharedInstance().setActive(false)
            state.accept(.systemPaused)
        case .ended:
            guard state.value == .systemPaused else { return }
            try? AVAudioSession.sharedInstance().setActive(true)
            sleep(1) //freaking magic
            try? audioEngine.start()
            state.accept(.performing)
        @unknown default:
            return
        }
    }
}
