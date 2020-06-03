//
//  AudioPlayerTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import AVFoundation
import sleeptestapp

class AudioPlayerTests: XCTestCase {
    
    override func setUp() {
        AVAudioSession.sharedInstance().requestRecordPermission { (_) in }
    }
    
    func test_StoppedState_OnInit() {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_PerformingState() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        var outpuBuffers = [AVAudioPCMBuffer]()
        let outputNode = services.engine.mainMixerNode
        outputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer, _) in
            outpuBuffers.append(buffer)
        }
        sut.start()
        let expect = expectation(description: "Player")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertEqual(spy.values, [.stopped, .performing])
        XCTAssert(outpuBuffers.count > 0)
    }
    
    func test_PauseState() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        sut.start()
        let player = try XCTUnwrap(services.engine.audioPlayerNode, "Expecting Player to be connected")
        
        sut.pause()
        XCTAssert(!player.isPlaying)
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused])
    }
    
    func test_ResumeState() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        sut.start()
        let player = try XCTUnwrap(services.engine.audioPlayerNode, "Expecting Player to be connected")
        XCTAssert(player.isPlaying)
        
        sut.pause()
        XCTAssert(!player.isPlaying)
        
        sut.resume()
        XCTAssert(player.isPlaying)
        XCTAssertEqual(spy.values, [.stopped, .performing, .paused, .performing])
    }
    
    func test_StoppedState() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start()
        let player = try XCTUnwrap(services.engine.audioPlayerNode, "Expecting Player to be connected")
        sut.stop()
        XCTAssert(!player.isPlaying)
        XCTAssertEqual(spy.values, [.stopped, .performing, .stopped])
    }
    
    func test_NoStateChange_PriorStart() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        sut.pause()
        sut.resume()
        sut.stop()
        XCTAssertEqual(spy.values, [.stopped])
    }
    
    func test_NoMultipleStarts() throws {
        let (sut, _) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        
        sut.start()
        sut.start()
        sut.start()
        XCTAssertEqual(spy.values, [.stopped, .performing])
    }
    
    //MARK: System Pause
    
    func test_SystemPausedState() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start()
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssert(!services.engine.isRunning)
        XCTAssertEqual(spy.values, [.stopped, .performing, .systemPaused])
    }
    
    func test_PerformingState_AfterSystemPaused() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start()
        let player = try XCTUnwrap(services.engine.audioPlayerNode, "Expecting Player to be connected")
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssert(!services.engine.isRunning)
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        XCTAssert(player.isPlaying)
        XCTAssertEqual(spy.values, [.stopped, .performing, .systemPaused, .performing])
    }
    
    func test_NoStateChange_ForUnknownParameter() throws {
        let (sut, services) = makeSUT()
        let spy = Spy<AudioServiceState>(observable: sut.state.asObservable())
        sut.start()
        let player = try XCTUnwrap(services.engine.audioPlayerNode, "Expecting Player to be connected")
        
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: 1111])
        
        XCTAssert(player.isPlaying)
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
    
    //MARK: - Helpers
    
    func makeSUT() -> (sut: AudioPlayer, services: ( engine: AVAudioEngine, mediaProvider: MediaProvider)) {
        let engine = AVAudioEngine()
        let (melody, alarm) = validMedia()
        let melodyProvider = LocalMediaProvider(melody: melody, alarm: alarm)
        guard let fileUrl = try? melodyProvider.melodyUrl() else {
            fatalError("Failed to get Melody File URL")
        }
        let sut = AudioPlayer(audioEngine: engine, fileUrl: fileUrl)
        return (sut, (engine, melodyProvider))
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

private extension AVAudioEngine {
    var audioPlayerNode: AVAudioPlayerNode? {
        for node in self.attachedNodes {
            if let player = node as? AVAudioPlayerNode {
                return player
            }
        }
        return nil
    }
}
