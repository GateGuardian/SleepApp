//
//  SettingViewModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

public struct SettingViewModel {
    
    public var title: String
    public var value = BehaviorRelay<String?>(value: nil)
    public var didSelect =  PublishRelay<Void>()
    
    public init(title: String) {
        self.title = title
    }
}

extension SettingViewModel: Equatable {
    public static func == (lhs: SettingViewModel, rhs: SettingViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}
