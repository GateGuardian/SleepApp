//
//  AudioRecordingService.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public protocol AudioRecordingService: AudioService {
    func start(folderName: String)
}

enum AudioRecordingServiceError: Error {
    case cantCreateFolder(folderName: String)
}
