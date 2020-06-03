//
//  LocalMediaProvider.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 22.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation

public struct AudioFile {
    
    public let name: String
    public let `extension`: String
    public let bundle: Bundle
    
    public init(name: String, `extension`: String, bundle: Bundle = Bundle.main) {
        self.name = name
        self.extension = `extension`
        self.bundle = bundle
    }
}

public class LocalMediaProvider {
    private let melody: AudioFile
    private let alarm: AudioFile
    
    public init(melody: AudioFile, alarm: AudioFile) {
        self.melody = melody
        self.alarm = alarm
    }
    
    private func urlFor(name: String, withExtension: String, bundle: Bundle) throws -> URL {
        guard
            let url = bundle.url(forResource: name, withExtension: withExtension)
        else {
            throw MediaProviderError.cantFindMediaFile(name: name)
        }
        return url
    }
}

extension LocalMediaProvider: MediaProvider {
    public func melodyUrl() throws -> URL {
        return try urlFor(name: melody.name, withExtension: melody.extension, bundle: melody.bundle)
    }
    
    public func alarmUrl() throws -> URL {
        return try urlFor(name: alarm.name, withExtension: alarm.extension, bundle: alarm.bundle)
    }
}
