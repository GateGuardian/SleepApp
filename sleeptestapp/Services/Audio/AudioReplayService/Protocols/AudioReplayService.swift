//
//  AudioReplayService.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol AudioReplayService: AudioService {
    func start()
    func setVolume(_ volume: Float)
}

public enum AudioReplayServiceError: Error {
    case failedToCreateAudioBuffer
}

extension AudioReplayServiceError: LocalizedError {
    
    public var errorDescription: String? {
        let description: String
        switch self {
        case .failedToCreateAudioBuffer:
            description = "Oops.. Failed to create Audio File buffer =("
        }
        return description
    }
    
}
