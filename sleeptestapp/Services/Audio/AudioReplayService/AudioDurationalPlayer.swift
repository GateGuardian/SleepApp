//
//  AudioDurationalPlayer.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import AVFoundation
import RxRelay
import RxSwift

public class AudioDurationalPlayer: AudioDurationalReplayService {
    
    var resumeTime: DispatchTime = .now()
    public var durationLeft = 0
    public var stopItem: DispatchWorkItem?
    
    public var timer: Timer?
    var startDate = Date()
    
    private let disposeBag = DisposeBag()
    
    public var state: BehaviorRelay<AudioServiceState> {
        player.state
    }
    
    var player: AudioReplayService
    
    public init(player: AudioReplayService) {
        self.player = player
        notificationSubscription()
    }
    
    public func start(duration: Int) {
        durationLeft = duration
        dispatchNewStop()
        player.start()
    }
    
    public func setVolume(_ volume: Float) {
        player.setVolume(volume)
    }
    
    public func pause() {
        handlePause()
        player.pause()
    }
    
    public func resume() {
        dispatchNewStop()
        player.resume()
    }
    
    public func stop() {
        print("Durational Player Stop")
        player.stop()
    }
    
    public func reset() {
        player.reset()
    }
    
    //MARK: - Private
    
    private func dispatchNewStop() {
        print("Dispatching New Stop with duration: \(durationLeft)")
        print("Dispatching Date: \(Date())")
        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(durationLeft), repeats: false) { [weak self] (_) in
            print("Timer fired: Stop")
            print("Fire Date: \(Date())")
            self?.stop()
        }
        self.timer = timer
        startDate = Date()
    }
    
    private func handlePause() {
        timer?.invalidate()
        timer = nil
        print("Calculating new duration")
        print("Old duration: \(durationLeft)")
        durationLeft = durationLeft -  (Int(Date().timeIntervalSince1970) - Int(startDate.timeIntervalSince1970))
        print("New duration: \(durationLeft)")
    }
    
    private func stopWorkItem() -> DispatchWorkItem {
        return DispatchWorkItem { [weak self] in
            self?.stop()
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
            guard timer != nil else { return }
            handlePause()
        case .ended:
            guard durationLeft != 0 else { return }
            dispatchNewStop()
        @unknown default:
            return
        }
    }
}
