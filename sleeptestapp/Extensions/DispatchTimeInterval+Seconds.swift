//
//  DispatchTimeInterval+Seconds.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public extension DispatchTimeInterval {
    var seconds: Int {
        switch self {
        case .seconds(let s): return s
        case .milliseconds(let ms): return ms / 1_000 // rounds toward zero
        case .microseconds(let us): return us / 1_000_000 // rounds toward zero
        case .nanoseconds(let ns): return ns / 1_000_000_000 // rounds toward zero
        case .never: return .max
        @unknown default:
            return 0
        }
    }
}
