//
//  AlarmScheduler.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

let AlarmTitle = "Alarm went off"

public class AlarmScheduler: NSObject, AlarmSchedulerProtocol {
    public var alarmTriggered = PublishRelay<Void>()
    public var timer: Timer?
    
    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func schedule(date: Date) {
        let nowDate = Date()
        let duration = Int(date.timeIntervalSince1970) - Int(nowDate.timeIntervalSince1970)
        startTimer(duration: duration)
        scheduleAlarmNotification(for: date)
    }
    
    public func resetScheduledAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - Private
    
    private func startTimer(duration: Int) {
        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { [weak self] (_) in
            self?.alarmTriggered.accept(())
            print("Fire date: \(Date())")
        }
        self.timer = timer
    }
    
    //MARK: Notification
    
    private func scheduleAlarmNotification(for date: Date) {
        let dateComponents = dateComponenets(from: date)
        let content = notificationContent()
        let center = UNUserNotificationCenter.current()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
//            print(error as Any)
        }
    }
    
    private func dateComponenets(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return dateComponents
       
    }
       
    private func notificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = AlarmTitle
        content.body = AlarmTitle
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        return content
    }
}

extension AlarmScheduler: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var options: UNNotificationPresentationOptions = []
        if UIApplication.shared.applicationState == .background {
            options = [UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound, UNNotificationPresentationOptions.badge]
        }
        completionHandler(options)
    }
}
