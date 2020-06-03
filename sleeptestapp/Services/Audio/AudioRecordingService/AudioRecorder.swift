//
//  AudioRecorder.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import AVFoundation
import RxRelay

public class AudioRecorder: AudioRecordingService {
    public var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    var audioEngine: AVAudioEngine
    var inputNode: AVAudioInputNode
    
    public init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
        self.inputNode = audioEngine.inputNode
        notificationSubscription()
    }
    
    public func start(folderName: String) {
        switch state.value {
        case .stopped:
            executeStart(folderName: folderName)
        default:
            return
        }
    }
    
    public func pause() {
        guard state.value == .performing, audioEngine.isRunning else { return }
        audioEngine.pause()
        state.accept(.paused)
    }
    
    public func resume() {
        guard (state.value == .paused || state.value == .systemPaused), !audioEngine.isRunning else { return }
        do {
            try audioEngine.start()
            state.accept(.performing)
        } catch let error {
            state.accept(.error(error))
        }
    }
    
    public func stop() {
        guard state.value != .stopped else { return }
        inputNode.removeTap(onBus: 0)
        state.accept(.stopped)
    }
    
    public func reset() {
        stop()
        audioEngine.stop()
    }
    
    //MARK: - Private
    
    private func executeStart(folderName: String) {
        do {
            let url = try recordUrl(folderName: folderName)
            let outputFile = try AVAudioFile(forWriting: url, settings: inputNode.outputFormat(forBus: 0).settings)
            inputNode.installTap(onBus: 0, bufferSize: 2048, format: inputNode.outputFormat(forBus: 0), block:
            {[weak self] (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                do {
                    try outputFile.write(from: buffer)
                }
                catch let error {
                    self?.audioEngine.stop()
                    self?.state.accept(.error(error))
                }
            })
            try audioEngine.start()
            state.accept(.performing)
        } catch let error {
            audioEngine.stop()
            state.accept(.error(error))
        }
        
    }
    
    private func recordUrl(folderName: String) throws -> URL {
        let url = try folderUrl(with: folderName)
        return url.appendingPathComponent(Constants.RecordName)
    }
    
    private func folderUrl(with folderName: String) throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AudioRecordingServiceError.cantCreateFolder(folderName: folderName)
        }
        guard !folderName.isEmpty else {
            return documentsDirectory
        }
        let folderUrl = documentsDirectory.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: folderUrl.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
        }
        return folderUrl
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
            state.accept(.systemPaused)
        case .ended:
            guard state.value == .systemPaused else { return }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                sleep(1) //freaking magic
                try audioEngine.start()
                state.accept(.performing)
            } catch let error {
                state.accept(.error(error))
            }
        @unknown default:
            return
        }
    }
}

extension AudioRecorder {
    private struct Constants {
        static let RecordName = "record.caf"
    }
}
