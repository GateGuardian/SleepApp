//
//  SleepInteractorStubs.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import sleeptestapp

public class SleepInteractorStub: SleepInteractorProtocol {
    
    private let bag = DisposeBag()
    public var start = PublishRelay<Void>()
    public var state = BehaviorRelay<SleepInteractorState>(value: .initial)
    public var reset = PublishRelay<Void>()
    
    public init() {
        start.subscribe(onNext: {[state] (_) in
            switch state.value {
                case .initial,
                     .replayPauseByUser:
                    state.accept(.replay)
                case .replay:
                    state.accept(.replayPauseByUser)
                case .recording:
                    state.accept(.recordingPauseByUser)
                default:
                    return
                }
        }).disposed(by: bag)
        reset.subscribe(onNext: {[state] in
            state.accept(.initial)
        }).disposed(by: bag)
    }
    
    public func setAlarm(date: Date) -> Observable<Date?> {
        return .just(date)
    }
    
    public func setSleepTimer(duration: Int) -> Observable<Int?> {
        return .just(duration)
    }
    
    public func setRecording(enabled: Bool) {
        
    }
}

public class SleepInteractorErrorStub: SleepInteractorProtocol {
    
    private let bag = DisposeBag()
    public var start = PublishRelay<Void>()
    public var alarmEnd = PublishRelay<Void>()
    public var error: SleepSetupValidationError
    public var state = BehaviorRelay<SleepInteractorState>(value: .initial)
    public var reset = PublishRelay<Void>()
    
    
    internal init(error: SleepSetupValidationError) {
        self.error = error
        start.subscribe(onNext: {[state] (_) in
            state.accept(.error(error))
        }).disposed(by: bag)
    }
    
    public func setAlarm(date: Date) -> Observable<Date?> {
        state.accept(.error(error))
        return .empty()
    }
       
    public func setSleepTimer(duration: Int) -> Observable<Int?> {
        state.accept(.error(error))
        return .empty()
    }
    
    public func setRecording(enabled: Bool) {
        
    }
}
