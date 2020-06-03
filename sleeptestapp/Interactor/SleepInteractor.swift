//
//  SleepInteractor.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 20.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class SleepInteractor: SleepInteractorProtocol {
    
    public var date: Date?
    public var duration: Int?
    public var recordingEnabled = true
    
    public var state = BehaviorRelay<SleepInteractorState>(value: .initial)
    public var start = PublishRelay<Void>()
    public var reset = PublishRelay<Void>()
    
    private let startValidator: SleepSetupValidator
    private let alarmValidator: DateValidator
    private let intersectionValidator: IntersectionValidator
    
    private let melodyPlayer: AudioDurationalReplayService
    private let recorder: AudioRecordingService
    private let mediaProvider: MediaProvider
    
    private let alarmPlayer: AudioReplayService
    private let alarmScheduler: AlarmSchedulerProtocol
    
    private let sessionConfigurator: AudioSessionConfigurator
    
    private let disposeBag = DisposeBag()
    
    public init(startValidator: SleepSetupValidator, alarmValidator: DateValidator, intersectionValidator: IntersectionValidator, melodyPlayer: AudioDurationalReplayService, recorder: AudioRecordingService, mediaProvider: MediaProvider, alarmPlayer: AudioReplayService, alarmScheduler: AlarmSchedulerProtocol, sessionConfigurator: AudioSessionConfigurator) {
        self.startValidator = startValidator
        self.alarmValidator = alarmValidator
        self.intersectionValidator = intersectionValidator
        self.melodyPlayer = melodyPlayer
        self.recorder = recorder
        self.mediaProvider = mediaProvider
        self.alarmPlayer = alarmPlayer
        self.alarmScheduler = alarmScheduler
        self.sessionConfigurator = sessionConfigurator
        self.subscribe()
    }
    
    public func setAlarm(date: Date) -> Observable<Date?> {
        do {
            let date = date.dateAccurateToMinutes()
            try validatePickedDate(date: date)
            self.date = date
            return .just(date)
        } catch let error {
            state.accept(.error(error))
            return .empty()
        }
    }
    
    public func setSleepTimer(duration: Int) -> Observable<Int?> {
        do {
            if let date = date {
                try intersectionValidator.validate(alarmDate: date, sleepTimeDuration: duration)
            }
            self.duration = duration
            return .just(duration)
        } catch let error {
            state.accept(.error(error))
            return .empty()
        }
    }
    
    public func setRecording(enabled: Bool) {
        recordingEnabled = enabled
    }
    
    //MARK: - Private
    
    private func subscribe() {
        startSubscribe()
        melodyStateSubscribe()
        recorderStateSubscribe()
        alarmTrigerredSubscribe()
        resetSubscribe()
    }
    
    private func startSubscribe() {
        start.subscribe(onNext: { [weak self] (_) in
            self?.handleStartAction()
        }).disposed(by: disposeBag)
    }
    
    private func melodyStateSubscribe() {
        melodyPlayer.state.skip(1).subscribe(onNext: {[weak self] (state) in
            switch state {
            case .stopped:
                self?.startRecording()
            case .performing:
                self?.state.accept(.replay)
            case .paused:
                self?.state.accept(.replayPauseByUser)
            case .systemPaused:
                self?.state.accept(.replayPause)
            case .error(let error):
                self?.state.accept(.error(error))
            }
        }).disposed(by: disposeBag)
    }
    
    private func recorderStateSubscribe() {
        recorder.state.skip(1).subscribe(onNext: {[weak self] (state) in
            switch state {
            case .stopped:
                print("Recorder stopped")
                return
            case .performing:
                self?.state.accept(.recording)
            case .paused:
                self?.state.accept(.recordingPauseByUser)
            case .systemPaused:
                self?.state.accept(.recordingPause)
            case .error(let error):
                self?.state.accept(.error(error))
            }
        }).disposed(by: disposeBag)
    }
    
    private func alarmPlayerStateSubscribe() {
        alarmPlayer.state.skip(1).subscribe(onNext: {[weak self] (state) in
            switch state {
            case .stopped:
                self?.alarmPlayer.reset()
            default:
                return
            }
        }).disposed(by: disposeBag)
    }
    
    private func alarmTrigerredSubscribe() {
        alarmScheduler.alarmTriggered.subscribe(onNext: {[weak self] (_) in
            self?.handleAlarm()
        }).disposed(by: disposeBag)
    }
    
    private func resetSubscribe() {
        reset.subscribe(onNext: {[weak self] (_) in
            self?.executeReset()
        }).disposed(by: disposeBag)
    }
    
    //MARK: Action Hanlder
    
    private func handleStartAction() {
        switch self.state.value {
        case .initial:
            self.handleStart()
        case .replay:
            self.melodyPlayer.pause()
        case .recording:
            self.recorder.pause()
        case .replayPauseByUser,
             .replayPause:
            self.melodyPlayer.resume()
        case .recordingPauseByUser,
             .recordingPause:
            self.recorder.resume()
        default:
            break
        }
    }
    
    //MARK: Start Sequence
    
    private func handleStart() {
        do {
            try sessionConfigurator.setup()
            let (alarmDate, duration) = try startValidator.validate(alarmDate: self.date, sleepTimeDuration: self.duration)
            alarmScheduler.schedule(date: alarmDate)
            if duration > 0 {
                startReplay(duration: duration)
            } else {
                startRecording()
            }
        } catch let error {
            self.state.accept(.error(error))
        }
    }
    
    private func startReplay(duration: Int) {
        melodyPlayer.start(duration: duration)
    }
    
    private func startRecording() {
        guard recordingEnabled else {
            //TODO: start silent replay
            alarmPlayer.setVolume(0.0)
            alarmPlayer.start()
            state.accept(.waitingForAlarm)
            return
        }
        switch state.value {
        case .error(_):
            return
        default:
            recorder.start(folderName: Date().toString())
        }
    }
    
    //MARK: Alarm

    private func handleAlarm() {
        recorder.stop()
        alarmPlayer.setVolume(1.0)
        alarmPlayer.start()
        state.accept(.alarm)
    }
    
    private func handleAlarmEnd() {
        executeReset()
    }
    
    //MARK: Validations
    
    private func validatePickedDate(date: Date) throws {
        try alarmValidator.validate(date: date)
        if let duration = duration {
            try intersectionValidator.validate(alarmDate: date, sleepTimeDuration: duration)
        }
    }
    
    //MARK: Reset
    
    private func executeReset() {
        recorder.reset()
        melodyPlayer.reset()
        alarmPlayer.reset()
        alarmScheduler.resetScheduledAlarms()
        date = nil
        duration = nil
        state.accept(.initial)
    }
}
