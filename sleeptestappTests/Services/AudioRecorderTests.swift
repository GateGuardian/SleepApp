//
//  AudioRecorderTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import AVFoundation
import sleeptestapp

class AudioRecorderTests: XCTestCase {
    
    override func setUp() {
        AVAudioSession.sharedInstance().requestRecordPermission { (_) in }
    }
    
    func test_StoppedState_OnInit() {
        let sut = AudioRecorder(audioEngine: AVAudioEngine())
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_PerformigState_OnStart_StoppedState_OnStop() {
        let fullTestDuration = 5
        let testTimeoutMargin = 1
        let (sut, engine) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        sut.start(folderName: "dummy")
        let expect = expectation(description: "Recording")
        XCTAssert(engine.isRunning)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(fullTestDuration)) {
            sut.stop()
            expect.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(fullTestDuration + testTimeoutMargin), handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .stopped])
    }
    
    func test_PauseState_OnPause_PerformingState_OnResume() {
        let durationTillPause = 3
        let fullTestDuration = durationTillPause + 2
        let (sut, engine) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(folderName: "dummy")
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(durationTillPause)) {
            sut.pause()
            XCTAssert(!engine.isRunning)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(durationTillPause + 1)) {
            sut.resume()
            XCTAssert(engine.isRunning)
        }
        let expect = expectation(description: "Recording")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(fullTestDuration)) {
            sut.stop()
            expect.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(fullTestDuration), handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused, .performing, .stopped])
    }
    
    func test_SystemPausedState_OnSystemInterruptionBegin_AndPerformingState_OnSystemInterruptionEnd() {
        let durationTillPause = 3
        let fullTestDuration = durationTillPause + 2
        let (sut, engine) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(folderName: "dummy")
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssert(!engine.isRunning)
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        XCTAssert(engine.isRunning)
        
        let expect = expectation(description: "Recording")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(fullTestDuration)) {
            sut.stop()
            expect.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(fullTestDuration), handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing, .systemPaused, .performing, .stopped])
    }
    
    func test_NoStateChange_ForUnknownParameter() throws {
        let (sut, engine) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(folderName: "dummy")

        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: 1111])
        XCTAssert(engine.isRunning)
        XCTAssertEqual(spy.values, [.stopped, .performing])
    }
    
    func test_NoStateChange_OnSystemInterruptionBegin_If_NotPerformingState() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_NoStateChange_OnSystemInterruptionEnd_If_NotSystemPausedState() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_NotPausing_WhileStateIsStoppedOrError_And_EngineIsNotRuning() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.pause()
        XCTAssertEqual(spy.values, [.stopped])
        
        sut.state.accept(.error(DummyError()))
        sut.pause()
        XCTAssertEqual(spy.values, [.stopped, .error(DummyError())])
    }
    
    func test_NotResuming_WhileStateIsStoppedOrError_And_EngineIsNotRuning() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.resume()
        XCTAssertEqual(spy.values, [.stopped])
        
        sut.state.accept(.error(DummyError()))
        sut.resume()
        XCTAssertEqual(spy.values, [.stopped, .error(DummyError())])
    }
    
    func test_NotStopping_WhileStateIsStopped() {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.stop()
        
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_NoMultipleStarts() {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start(folderName: "dummy")
        sut.start(folderName: "drummy")
        sut.start(folderName: "durmmy")
        
        XCTAssertEqual(spy.values, [.stopped, .performing])
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> (sut: AudioRecorder, engine: AVAudioEngine) {
        let engine = AVAudioEngine()
        let sut = AudioRecorder(audioEngine: engine)
        return (sut, engine)
    }
}
