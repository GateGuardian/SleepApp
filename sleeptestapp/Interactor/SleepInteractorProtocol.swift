//
//  SleepInteractor.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

public protocol SleepInteractorProtocol {
    var state: BehaviorRelay<SleepInteractorState> { get }
    
    var start: PublishRelay<Void> { get }
    
    var reset: PublishRelay<Void> { get }
    
    func setAlarm(date: Date) -> Observable<Date?>
    
    func setSleepTimer(duration: Int) -> Observable<Int?>
    
    func setRecording(enabled: Bool)
}

public enum SleepInteractorState: Equatable {
    case initial
    case replay
    case replayPause
    case replayPauseByUser
    case recording
    case recordingPause
    case recordingPauseByUser
    case waitingForAlarm
    case alarm
    case error(Error)
    
    public static func == (lhs: SleepInteractorState, rhs: SleepInteractorState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.recording, .recording),
             (.replay, .replay),
             (.replayPauseByUser, .replayPauseByUser),
             (.replayPause, .replayPause),
             (.alarm, .alarm),
             (.recordingPauseByUser, .recordingPauseByUser),
             (.recordingPause, .recordingPause),
             (.error, .error),
             (.waitingForAlarm, .waitingForAlarm):
            return true
        default:
            return false
        }
    }
}

public enum SleepSetupValidationError: Error {
    case alarmAndSleepTimerIntersect //alarm will fire before lalaby ends
    case alarmNotSet
    case sleepTimerDurationNotSet
    case alarmSetInPast
}

extension SleepSetupValidationError: LocalizedError {
    public var errorDescription: String? {
        let description: String
        switch self {
        case .alarmAndSleepTimerIntersect:
            description = "You set alarm to soon! The lalaby won't have enough time to finish!"
        case .alarmNotSet:
            description = "Alarm Time not set! Please set the Alarm Time."
        case .sleepTimerDurationNotSet:
            description = "Lalaby duration not set! Please select the desired Lalaby Duration or turn it off."
        case .alarmSetInPast:
            description = "You set alarm in past! Delorian is currently not available =(."
        }
        return description
    }
}
