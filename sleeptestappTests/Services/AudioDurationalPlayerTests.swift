//
//  AudioDurationalPlayerTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import AVFoundation
import sleeptestapp
import RxRelay
import RxSwift

class AudioDurationalPlayerTests: XCTestCase {
    
    var bag = DisposeBag()
    
    func test_StoppedState_OnInit() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_PerformingState_OnStart() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(duration: 10)
        
        XCTAssertEqual(spy.values, [.stopped, .performing])
    }
    
    func test_PauseState() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(duration: 10)
        sut.pause()
        
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused])
    }
    
    func test_PerformingState_OnResume() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(duration: 10)
        sut.pause()
        sut.resume()
        
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused, .performing])
    }
    
    func test_StopedState_AfterTimeRunsOut() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(duration: 10)
        let expect = expectation(description: "Player")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 11, handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .stopped])
    }
    
    func test_StopedStatePostponed_OnPause() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        let replayDuration = 10
        let prePauseDuration = 3
        let pauseDuration = 3
        sut.start(duration: replayDuration)
        let start = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: start + DispatchTimeInterval.seconds(prePauseDuration)) {
            sut.pause()
            XCTAssertEqual(sut.durationLeft, replayDuration - prePauseDuration)
        }
        DispatchQueue.main.asyncAfter(deadline: start + DispatchTimeInterval.seconds(pauseDuration + prePauseDuration)) {
            sut.resume()
        }
        sut.state.subscribe(onNext: { (state) in
            if state == .stopped {
                let aproximateEnd = start + DispatchTimeInterval.seconds(replayDuration + pauseDuration)
                let distance = aproximateEnd.distance(to: .now())
                XCTAssertEqual(distance.seconds, 0)
            }
        }).disposed(by: bag)
        
        let margin = 1
        let timeout = replayDuration + pauseDuration + margin
        let expect = expectation(description: "Player")
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(timeout)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused, .performing, .stopped])
        bag = DisposeBag()
    }
    
    func test_StopedStatePostponed_OnSystemPause() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        let replayDuration = 10
        let prePauseDuration = 3
        let pauseDuration = 3
//        let url = try XCTUnwrap(mediaProvider.melodyUrl())
        sut.start(duration: replayDuration)
        let start = DispatchTime.now()
        let startDate = Date()
        DispatchQueue.main.asyncAfter(deadline: start + DispatchTimeInterval.seconds(prePauseDuration)) {
            NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
            XCTAssertEqual(sut.durationLeft, replayDuration - prePauseDuration)
        }
        DispatchQueue.main.asyncAfter(deadline: start + DispatchTimeInterval.seconds(pauseDuration + prePauseDuration)) {
            NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        }
        sut.state.subscribe(onNext: { (state) in
            let nowTimeInterval = Int(Date().timeIntervalSince1970)
            if state == .stopped {
                let aproximateEnd = Int(startDate.timeIntervalSince1970) + replayDuration + pauseDuration
                print("Now: \(nowTimeInterval), Aprx: \(aproximateEnd)")
                let distance = nowTimeInterval - aproximateEnd
                XCTAssert(distance >= 0)
            }
        }).disposed(by: bag)
        
        let margin = 2
        let timeout = replayDuration + pauseDuration + margin
        let expect = expectation(description: "Player")
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(timeout)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .systemPaused, .performing, .stopped])
        bag = DisposeBag()
    }
    
    func test_NoPauseHandling_OnSystemInterruptionBegin_If_StopNotScheduled() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssertNil(sut.stopItem)
        XCTAssertEqual(sut.durationLeft, 0)
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_NoPauseHandling_OnSystemInterruptionEnd_If_DurationNotSet() throws {
        let sut = try makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        XCTAssertNil(sut.stopItem)
        XCTAssertEqual(sut.durationLeft, 0)
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    //MARK: - Helpers
    
    func makeSUT() throws -> AudioDurationalPlayer {
        let (melody, alarm) = validMedia()
        let mediaProvider = LocalMediaProvider(melody: melody, alarm: alarm)
        let fileUrl = try mediaProvider.melodyUrl()
        let player = AudioPlayer(audioEngine: AVAudioEngine(), fileUrl: fileUrl)
        let sut = AudioDurationalPlayer(player: player)
        
        return sut
    }
    
    func validMedia() -> (melody: AudioFile ,alarm: AudioFile) {
        return (AudioFile(name: "melody", extension: "m4a", bundle: Bundle(for: LocalMediaProviderTests.self)),
                AudioFile(name: "alarm", extension: "m4a", bundle: Bundle(for: LocalMediaProviderTests.self)))
    }
    
    func invalidMedia()-> (melody: AudioFile ,alarm: AudioFile) {
        return (AudioFile(name: "melody1", extension: "m4a"),
                AudioFile(name: "alarm1", extension: "m4a"))
    }
}

class AudioPlayerStub: AudioReplayService {
   
    var volume: Float = 1.0
    var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    
    init() {
        notificationSubscription()
    }
    
    func start() {
        state.accept(.performing)
    }
    
    func pause() {
        state.accept(.paused)
    }
    
    func resume() {
        state.accept(.performing)
    }
    
    func stop() {
        state.accept(.stopped)
    }
    
    func reset() {
        state.accept(.stopped)
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
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
            state.accept(.systemPaused)
        case .ended:
            guard state.value == .systemPaused else { return }
            state.accept(.performing)
        @unknown default:
            return
        }
    }
}
