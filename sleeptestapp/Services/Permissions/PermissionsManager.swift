//
//  PermissionsManager.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation
import RxSwift
import RxRelay

public class PermissionManager: PermissionsManagerProtocol {
    
    public init() { }
    
    public func checkNotificationsAllowed() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (subscriber) -> Disposable in
            self?.requestNotificationsPermissionsIfNeeded(subscriber: subscriber)
            return Disposables.create()
        }
    }
    
    public func checkMicAllowed() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (subscriber) -> Disposable in
            self?.requestMicPermissionsIfNeeded(subscriber: subscriber)
            return Disposables.create()
        }
    }
    
    //MARK: - Private
    
    //MARK: Mic
    func requestMicPermissionsIfNeeded(subscriber: AnyObserver<Bool>) {
        let micPermission = AVAudioSession.sharedInstance().recordPermission
        switch micPermission {
        case .denied:
            subscriber.onNext(false)
        case .undetermined:
            requestMicPermission(subscriber: subscriber)
        default:
            subscriber.onNext(true)
            break
        }
    }
    
    func requestMicPermission(subscriber: AnyObserver<Bool>) {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            subscriber.onNext(granted)
        }
    }
    
    //MARK: Notifications
    
    private func requestNotificationsPermissionsIfNeeded(subscriber: AnyObserver<Bool>) {
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (settings) in
            let notificationsPermission = settings.authorizationStatus
            switch notificationsPermission {
            case .denied:
                subscriber.onNext(false)
            case .notDetermined:
                self?.requestNotificationsPermissions(subscriber: subscriber)
            default:
                subscriber.onNext(true)
            }
        }
    }
    
    private func requestNotificationsPermissions(subscriber: AnyObserver<Bool>) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            subscriber.onNext(granted)
        }
    }
}
