//
//  Date+String.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter.string(from: self)
    }
    
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: self)
    }
    
    func dateAccurateToMinutes() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.second], from: self)
        let seconds: Double = Double(dateComponents.second ?? 0)
        return addingTimeInterval(-seconds)
    }
}
