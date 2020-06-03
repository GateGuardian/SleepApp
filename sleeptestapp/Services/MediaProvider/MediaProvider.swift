//
//  MediaProvider.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol MediaProvider {
    func melodyUrl() throws -> URL
    func alarmUrl() throws -> URL
}

public enum MediaProviderError: Error {
    case cantFindMediaFile(name: String)
}
