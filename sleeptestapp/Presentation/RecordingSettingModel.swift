//
//  RecordingSettingModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 19.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public struct RecordingSettingModel {
    public var title: String
    public var value = BehaviorRelay<String?>(value: nil)
    public var didSelect = PublishRelay<Void>()
    public var input = PublishRelay<Bool>()
    
    public init(title: String) {
        self.title = title
    }
}

extension RecordingSettingModel: Equatable {
    public static func == (lhs: RecordingSettingModel, rhs: RecordingSettingModel) -> Bool {
        return lhs.title == rhs.title
    }
}
