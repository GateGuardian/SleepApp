//
//  AudioSessionConfigurator.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 27.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol AudioSessionConfigurator {
    func setup() throws
    func setSession(active: Bool) throws
}
