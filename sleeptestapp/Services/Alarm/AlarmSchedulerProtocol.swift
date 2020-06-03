//
//  AlarmScheduler.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public protocol AlarmSchedulerProtocol {
    var alarmTriggered: PublishRelay<Void> { get }
    
    func schedule(date: Date)
    
    func resetScheduledAlarms()
}
