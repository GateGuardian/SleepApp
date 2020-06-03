//
//  ErrorFormatter.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol ErrorFormatter {
    func description(from error: Error) -> String
}
