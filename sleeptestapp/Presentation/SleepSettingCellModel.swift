//
//  SleepSettingCellModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 28.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxDataSources

public enum SleepSettingCellModel {
    case sleepTimer(SettingViewModel)
    case alarm(SettingViewModel)
    case recording(RecordingSettingModel)
}

extension SleepSettingCellModel: IdentifiableType {
    public var identity: String {
        switch self {
        case let .alarm(vm): return vm.title
        case let .recording(vm): return vm.title
        case let .sleepTimer(vm): return vm.title
        }
    }
}

extension SleepSettingCellModel: Equatable { }
