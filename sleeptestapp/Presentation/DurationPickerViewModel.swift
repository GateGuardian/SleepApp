//
//  DurationPickerViewModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public struct DurationPickerViewModel {
    public var title: String = "Sleep Timer"
    public var cancelTitle: String = "Cancel"
    public let options: [Int: String]
    public let sortedOptions: [(Int, String)]
    
    public let didSelectDuration: PublishRelay<Int>
    public let cancel: PublishRelay<Void>
    
    public init(_ didSelectDuration: PublishRelay<Int>, cancel: PublishRelay<Void>, options: [Int: String]) {
        self.didSelectDuration = didSelectDuration
        self.cancel = cancel
        self.options = options
        self.sortedOptions = Array(options).sorted { (tupple1, tupple2) -> Bool in
            tupple1.key < tupple2.key
        }
    }
}

extension DurationPickerViewModel: Equatable {
    public static func == (lhs: DurationPickerViewModel, rhs: DurationPickerViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.cancelTitle == rhs.cancelTitle && lhs.options == rhs.options
    }
}
