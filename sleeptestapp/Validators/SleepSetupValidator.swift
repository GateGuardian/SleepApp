//
//  SleepSetupValidator.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 21.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public struct SleepSetupValidator {
    private let dateValidator: DateValidator
    private let intersectionValidator: IntersectionValidator
    
    public init(dateValidator: DateValidator, intersectionValidator: IntersectionValidator) {
        self.dateValidator = dateValidator
        self.intersectionValidator = intersectionValidator
    }

    public func validate(alarmDate: Date?, sleepTimeDuration duration: Int?) throws -> (date: Date, duration: Int) {
        guard let date = alarmDate else { throw SleepSetupValidationError.alarmNotSet }
        guard let duration = duration else { throw SleepSetupValidationError.sleepTimerDurationNotSet }
        try dateValidator.validate(date: date)
        try intersectionValidator.validate(alarmDate: date, sleepTimeDuration: duration)
        return (date, duration)
    }
}

public struct DateValidator {
    
    public init() {}
    
    public func validate(date: Date) throws {
        if date < Date() { throw SleepSetupValidationError.alarmSetInPast }
    }
}
    
public struct IntersectionValidator {
    
    public init() {}
    
    public func validate(alarmDate: Date, sleepTimeDuration duration: Int) throws {
        let durationEndDate = Date(timeInterval: Double(duration), since: Date())
        if durationEndDate > alarmDate {
            throw SleepSetupValidationError.alarmAndSleepTimerIntersect
        }
    }
}
