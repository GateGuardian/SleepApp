//
//  AlarmViewModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 18.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public struct AlarmViewModel {
    public var title: String
    public var message: String
    public var stopTitle: String
    
    public var stop: PublishRelay<Void>
    
    public init(title: String = "Alarm", message: String = "Alar mwent off!", stopTitle: String = "Stop", accept: PublishRelay<Void>) {
        self.title = title
        self.message = message
        self.stopTitle = stopTitle
        self.stop = accept
    }
}

extension AlarmViewModel: Equatable {
    public static func == (lhs: AlarmViewModel, rhs: AlarmViewModel) -> Bool {
        return (lhs.title == rhs.title && lhs.stopTitle == rhs.stopTitle && lhs.message == rhs.message)
    }
}
