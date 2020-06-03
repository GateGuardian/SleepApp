//
//  SleepInteractorTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 20.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import sleeptestapp

class SleepInteractorTests: XCTestCase {
    
    func test_InitialState() {
        let (sut, _) = makeSUT()
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        XCTAssertEqual(spy.values, [SleepInteractorState.initial])
    }
    
    //MARK: - Date Validation
    
    func test_DateValidation_AlarmSetInPast() {
        let (sut, _) = makeSUT()
        
        let date = Date(timeIntervalSince1970: 0)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        _ = sut.setAlarm(date: date)
        XCTAssertEqual(spy.values, [.initial, .error(SleepSetupValidationError.alarmSetInPast)])
    }
    
    func test_DateValidation_AlarmAndSleepTimerIntersect() {
        let (sut, _) = makeSUT()
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        let duration = 10
        let margin = 2
        let alarmDate = Date(timeInterval: Double(duration - margin), since: Date())
        
        _ = sut.setSleepTimer(duration: duration)
        _ = sut.setAlarm(date: alarmDate)
        
        XCTAssertEqual(spy.values, [.initial, .error(SleepSetupValidationError.alarmAndSleepTimerIntersect)])
    }
    
    func test_DateValidation_NoSleepTimer_NoError() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let dateObservable = sut.setAlarm(date: alarmDate)
        let spy = Spy<Date?>(observable: dateObservable)
        
        XCTAssertEqual(spy.values, [alarmDate.dateAccurateToMinutes()])
    }
    
    func test_DateValidation_WithSleepTimer_NoError() {
        let (sut, _) = makeSUT()
        let duration = 10
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        _ = sut.setSleepTimer(duration: duration)
        let dateObservable = sut.setAlarm(date: alarmDate)
        let spy = Spy<Date?>(observable: dateObservable)
        
        XCTAssertEqual(spy.values, [alarmDate.dateAccurateToMinutes()])
    }
    
    //MARK: - Duration - Date Intersection Validation
 
    func test_DurationValidation_AlarmAndSleepTimerIntersect() {
        let (sut, _) = makeSUT()
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        let duration = 10
        let margin = 2
        let alarmDate = Date(timeInterval: Double(duration - margin), since: Date())
        _ = sut.setAlarm(date: alarmDate)
        
        _ = sut.setSleepTimer(duration: duration)

        
        XCTAssertEqual(spy.values, [.initial, .error(SleepSetupValidationError.alarmAndSleepTimerIntersect)])
    }
    
    //MARK: - Start Validation
    
    func test_StartValidation_AlarmNotSet() {
        let (sut, _) = makeSUT()
        let duration = 10
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .error(SleepSetupValidationError.alarmNotSet)])
    }
    
    func test_StartValidation_SleepTimerNotSet() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        _ = sut.setAlarm(date: alarmDate)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .error(SleepSetupValidationError.sleepTimerDurationNotSet)])
    }
    
    //MARK: - State
    
    //MARK: Replay
    
    func test_ReplayState_OnStart() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        let playerSpy = Spy<AudioServiceState>(observable: services.sleepMelodyPlayer.state.asObservable())
        
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .replay])
        XCTAssertEqual(playerSpy.values, [.stopped, .performing])
        XCTAssertEqual(duration, services.sleepMelodyPlayer.duration)
    }
    
    func test_ReplayPauseByUserState_OnPause() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .replay, .replayPauseByUser])
    }
    
    func test_ReplayState_AfterPause() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        sut.start.accept(())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .replay, .replayPauseByUser, .replay])
    }
    
    func test_ReplayState_AfterPausedBySystemRecover() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        services.sleepMelodyPlayer.systemPause()
        services.sleepMelodyPlayer.resume()
        
        XCTAssertEqual(spy.values, [.initial, .replay, .replayPause, .replay])
    }
    
    func test_ErrorState_OnStart_MelodyPlayerError() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        services.sleepMelodyPlayer.error = DummyError()
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .error(DummyError())])
    }
    
    func test_InitialState_AfterError() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        services.sleepMelodyPlayer.error = DummyError()
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        sut.reset.accept(())
        XCTAssert(services.scheduler.reset)
        XCTAssertNil(sut.date)
        XCTAssertNil(sut.duration)
        XCTAssertEqual(spy.values, [.initial, .error(DummyError()), .initial])
    }
    
    //MARK: Recording
    
    func test_RecordingState_OnStart() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        let recorderSpy = Spy<AudioServiceState>(observable: services.recorder.state.asObservable())
        
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .recording])
        XCTAssertEqual(recorderSpy.values, [.stopped, .performing])
        XCTAssert(services.recorder.folderName != "")
    }
    
    func test_RecordingPausedByUserState_OnPause() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .recording, .recordingPauseByUser])
    }
    
    func test_RecordingState_AfterPause() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        sut.start.accept(())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .recording, .recordingPauseByUser, .recording])
    }
    
    func test_RecordingState_AfterPausedBySystemRecover() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        services.recorder.systemPause()
        services.recorder.resume()
        
        XCTAssertEqual(spy.values, [.initial, .recording, .recordingPause, .recording])
    }
    
    func test_ErrorState_OnStart_RecorderError() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        services.recorder.error = DummyError()
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .error(DummyError())])
    }
    
    func test_NoRecording_IfRecordingDisabled() {
        let (sut, _) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        _ = sut.setRecording(enabled: false)
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        XCTAssertEqual(spy.values, [.initial, .waitingForAlarm])
    }
    
    func test_RecordingDisabled_AlarmPlayerPlays_WithZeroVolume() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        _ = sut.setRecording(enabled: false)
        
        
//        XCTAssertEqual(services.)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        XCTAssertEqual(services.alarmPlayer.volume, 0.0)
        XCTAssertEqual(services.alarmPlayer.state.value, .performing)
        XCTAssertEqual(spy.values, [.initial, .waitingForAlarm])
    }
    
    func test_RecordingDisabled_AlarmPlayerPlays_WithFullVolume_AfterAlarmTrigger() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 0
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        _ = sut.setRecording(enabled: false)
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        XCTAssertEqual(spy.values, [.initial, .waitingForAlarm])
        
        services.scheduler.alarmTriggered.accept(())
        
        XCTAssertEqual(services.alarmPlayer.volume, 1.0)
        XCTAssertEqual(services.alarmPlayer.state.value, .performing)
    }
    
    //MARK: - Sequence
    
    func test_MelodyEnd_RecordingStart() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        services.sleepMelodyPlayer.stop()
        
        XCTAssertEqual(spy.values, [.initial, .replay, .recording])
    }
    
    func test_AlarmState_AndRecordingStop_AfterAlarmTrigerred() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        let recorderStateSpy = Spy<AudioServiceState>(observable: services.recorder.state.asObservable())
        sut.start.accept(())
        services.sleepMelodyPlayer.stop()
        services.scheduler.alarmTriggered.accept(())
        
        XCTAssertEqual(recorderStateSpy.values, [.stopped, .performing, .stopped])
        XCTAssertEqual(spy.values, [.initial, .replay, .recording, .alarm])
    }
    
    func test_InitialState_AfterAlarmStop() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        services.sleepMelodyPlayer.stop()
        services.scheduler.alarmTriggered.accept(())
        sut.reset.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .replay, .recording, .alarm, .initial])
    }
    
    //MARK: - Alarm
    
    func test_AlarmScheduled_OnStart() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        sut.start.accept(())
        
        XCTAssertNotNil(services.scheduler.alarmDate)
        XCTAssertEqual(spy.values, [.initial, .replay])
    }
    
    func test_AlarmPlayerPerforming_OnAlarmState() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        
        let spy = Spy<AudioServiceState>(observable: services.alarmPlayer.state.asObservable())
        services.scheduler.alarmTriggered.accept(())
        
        XCTAssertEqual(spy.values, [.stopped, .performing])
    }
    
    func test_AlarmPlayerStopped_OnAlarmEnd() {
        let (sut, services) = makeSUT()
        let alarmDate = Date(timeInterval: 300.0, since: Date())
        let duration = 100
        _ = sut.setAlarm(date: alarmDate)
        _ = sut.setSleepTimer(duration: duration)
        
        let spy = Spy<AudioServiceState>(observable: services.alarmPlayer.state.asObservable())

        services.scheduler.alarmTriggered.accept(())
        sut.reset.accept(())
        
        XCTAssertEqual(spy.values, [.stopped, .performing, .stopped])
    }
    
    func test_StateNotChanged_OnSatrtAction_While_Error_Or_Alarm_State() {
        let (sut, services) = makeSUT()
        let spy = Spy<SleepInteractorState>(observable: sut.state.asObservable())
        services.scheduler.alarmTriggered.accept(())
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .alarm])
        
        sut.state.accept(.error(DummyError()))
        sut.start.accept(())
        
        XCTAssertEqual(spy.values, [.initial, .alarm, .error(DummyError())])
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> (sut: SleepInteractor, services: (sleepMelodyPlayer: SleepMelodyPlayerStub, alarmPlayer: AlarmPlayerStub, recorder: RecorderStub,  mediaProvider: MediaFileProviderStub, scheduler: AlarmSchedulerStub)) {
        let sleepMelodyPlayer = SleepMelodyPlayerStub()
        let alarmPlayer = AlarmPlayerStub()
        let recorder = RecorderStub()
        let mediaProvider = MediaFileProviderStub()
        let scheduler = AlarmSchedulerStub()
        
        let dateValidator = DateValidator()
        let intersectionValidator = IntersectionValidator()
        let mainValidator = SleepSetupValidator(dateValidator: dateValidator, intersectionValidator: intersectionValidator)
        
        let sut = SleepInteractor(startValidator: mainValidator, alarmValidator: dateValidator, intersectionValidator: intersectionValidator, melodyPlayer: sleepMelodyPlayer, recorder: recorder, mediaProvider: mediaProvider, alarmPlayer: alarmPlayer, alarmScheduler: scheduler, sessionConfigurator: SessionConfigurator())

        return (sut, (sleepMelodyPlayer, alarmPlayer, recorder, mediaProvider, scheduler))
    }
}

class ErrorSpy<T, E> {
    var errors: [E] = []
    var disposeBag = DisposeBag()
    
    init(observable: Observable<T>) {
        observable.subscribe(onError: {[weak self] (error) in
            guard let error = error as? E else { return }
            self?.errors.append(error)
        }).disposed(by: disposeBag)
    }
}

struct DummyError: Error {
    var localizedDescription: String {
        return "Dummy"
    }
}

class SleepMelodyPlayerStub: AudioDurationalReplayService {
    var volume: Float = 1.0
    var error: DummyError?
    var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    var duration: Int = 0
    
    func setVolume(_ volume: Float) {
        self.volume = volume
    }
    
    func start(duration: Int) {
//        guard state.value == .stopped else { return }
        if let error = error {
            self.state.accept(.error(error))
            return
        }
        self.duration = duration
        self.state.accept(.performing)
    }
    
    func pause() {
        guard state.value == .performing else { return }
        self.state.accept(.paused)
    }
    
    func resume() {
        guard (state.value == .paused || state.value == .systemPaused) else { return }
        self.state.accept(.performing)
    }
    
    func stop() {
        guard state.value != .stopped else { return }
        self.state.accept(.stopped)
    }
    
    func systemPause() {
        
        self.state.accept(.systemPaused)
    }
    
    func reset() {
        guard state.value != .stopped else { return }
        state.accept(.stopped)
    }
}

class AlarmPlayerStub: AudioReplayService {
    var volume: Float = 1.0
    var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    
    func setVolume(_ volume: Float) {
        self.volume = volume
    }
    
    func start() {
        self.state.accept(.performing)
    }
    
    func pause() {
        self.state.accept(.paused)
    }
    
    func resume() {
        self.state.accept(.performing)
    }
    
    func stop() {
        guard state.value != .stopped else { return }
        self.state.accept(.stopped)
    }
    
    func systemPause() {
        self.state.accept(.systemPaused)
    }
    
    func reset() {
        guard state.value != .stopped else { return }
        state.accept(.stopped)
    }
}

class RecorderStub: AudioRecordingService {
    
    var error: DummyError?
    var folderName: String = ""
    var state = BehaviorRelay<AudioServiceState>(value: .stopped)
    
    func setFolderName(_ name: String) {
        folderName = name
    }
    
    func start(folderName: String) {
        self.folderName = folderName
        if let error = error {
            self.state.accept(.error(error))
            return
        }
        self.state.accept(.performing)
    }
    
    func pause() {
        self.state.accept(.paused)
    }
    
    func resume() {
        self.state.accept(.performing)
    }
    
    func stop() {
        guard state.value != .stopped else { return }
        self.state.accept(.stopped)
    }
    
    func systemPause() {
        self.state.accept(.systemPaused)
    }
    
    func reset() {
        guard state.value != .stopped else { return }
        state.accept(.stopped)
    }
}

class MediaFileProviderStub: MediaProvider {
    var url: URL = URL(fileURLWithPath: "/dummy")
    var error: DummyError?
    
    func melodyUrl() throws -> URL {
        if let error = error {
            throw error
        }
        return url
    }
    
    func alarmUrl() throws -> URL {
        if let error = error {
            throw error
        }
        return url
    }
}

class AlarmSchedulerStub: AlarmSchedulerProtocol {
    
    var reset = false
    var alarmDate: Date?
    var alarmTriggered = PublishRelay<Void>()
    
    func schedule(date: Date) {
        alarmDate = date
    }
    
    func resetScheduledAlarms() {
        reset = true
    }
}
