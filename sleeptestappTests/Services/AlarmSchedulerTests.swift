//
//  AlarmSchedulerTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxSwift
import sleeptestapp

class AlarmSchedulerTests: XCTestCase {

    override func setUp() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _,_ in }
    }
    
    var bag = DisposeBag()
    
    func test_Alarm_Trigger() {
        let sut = AlarmScheduler()
        let alarmDate = Date(timeInterval: 10.0, since: Date())
        print("Alarm Date: \(alarmDate)")
        let expect = expectation(description: "Alarm")
        var fireDate: Date?
        sut.alarmTriggered.subscribe(onNext: { (_) in
            fireDate = Date()
            expect.fulfill()
        }).disposed(by: bag)
        
        sut.schedule(date: alarmDate)
        waitForExpectations(timeout: 11, handler: nil)
        XCTAssertEqual(alarmDate.toString(), fireDate?.toString())
        bag = DisposeBag()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func test_LocalNotification() {
        let sut = AlarmScheduler()
        let alarmDate = Date(timeInterval: 100.0, since: Date())
        sut.schedule(date: alarmDate)
        var didScheduleNotification = false
        let center = UNUserNotificationCenter.current()
        let expect = expectation(description: "Alarm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            center.getPendingNotificationRequests { (requests) in
                print(requests.count)
                for request in requests {
                    if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
                        calendarTrigger.dateComponents == alarmDate.dateComponenets(),
                        request.content.categoryIdentifier == "alarm" {
                            didScheduleNotification = true
                            center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                            expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 11, handler: nil)
        XCTAssert(didScheduleNotification)
    }
    
    func test_Reset() {
        let sut = AlarmScheduler()
        let alarmDate = Date(timeInterval: 100.0, since: Date())
        sut.schedule(date: alarmDate)
        sut.resetScheduledAlarms()
        let expect = expectation(description: "Get Pending Requests")
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            XCTAssert(requests.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertNil(sut.timer)
    }
}

private extension Date {
    func dateComponenets() -> DateComponents {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return dateComponents
    }
}
