//
//  PermissionsManagerProtocol.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxSwift

public protocol PermissionsManagerProtocol {
    func checkNotificationsAllowed() -> Observable<Bool>
    func checkMicAllowed() -> Observable<Bool>
}
