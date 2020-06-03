//
//  SessionConfigurator.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 01.06.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import AVFoundation

public class SessionConfigurator: AudioSessionConfigurator {
    public init() { }
    
    public func setup() throws {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
    }
    
    public func setSession(active: Bool) throws {
        try AVAudioSession.sharedInstance().setActive(active)
    }
}
