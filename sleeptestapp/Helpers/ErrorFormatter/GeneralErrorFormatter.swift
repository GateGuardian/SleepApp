//
//  GeneralErrorFormatter.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public class GeneralErrorFormatter: ErrorFormatter {
    public init() {}
    
    public func description(from error: Error) -> String {
        var message = "Unknown Error"
        if let error = error as? LocalizedError, let description = error.errorDescription {
            message = description
        } else {
            message = error.localizedDescription
        }
        return message
    }
}
