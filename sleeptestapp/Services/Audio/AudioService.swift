//
//  AudioService.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxRelay

public protocol AudioService {
    var state: BehaviorRelay<AudioServiceState> { get }
    
    func pause()
    
    func resume()
    
    func stop()
    
    func reset()
}

public enum AudioServiceState {
    case stopped
    case performing
    case paused
    case systemPaused
    case error(Error)
}

extension AudioServiceState: Equatable {
    public static func == (lhs: AudioServiceState, rhs: AudioServiceState) -> Bool {
        switch (lhs, rhs) {
        case (.stopped, .stopped),
             (.performing, .performing),
             (.systemPaused, .systemPaused),
             (.paused, .paused),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}
