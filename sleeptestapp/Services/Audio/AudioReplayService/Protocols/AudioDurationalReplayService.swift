//
//  AudioDurationalReplayService.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol AudioDurationalReplayService: AudioService {
    func start(duration: Int)
    func setVolume(_ volume: Float)
}
