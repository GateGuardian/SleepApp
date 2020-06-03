//
//  DatePickerViewModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public struct DatePickerViewModel {
    public var title: String = "Alarm"
    public var cancelTitle: String = "Cancel"
    public var selectTitle: String = "Done"
    
    public let didSelectDate: PublishRelay<Date>
    public let cancel: PublishRelay<Void>
    
    public init(_ didSelectDate: PublishRelay<Date>, cancel: PublishRelay<Void>) {
        self.didSelectDate = didSelectDate
        self.cancel = cancel
    }
}

extension DatePickerViewModel: Equatable {
    public static func == (lhs: DatePickerViewModel, rhs: DatePickerViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.cancelTitle == rhs.cancelTitle && lhs.selectTitle == rhs.selectTitle
    }
}
