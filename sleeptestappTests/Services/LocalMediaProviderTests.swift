//
//  LocalMediaProviderTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 25.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import sleeptestapp

class LocalMediaProviderTests: XCTestCase {
    
    func test_UrlForAlarmAndMelody_NoError() {
        let media = validMedia()
        let sut = LocalMediaProvider(melody: media.melody, alarm: media.alarm)
        XCTAssertNoThrow(try sut.alarmUrl())
        XCTAssertNoThrow(try sut.melodyUrl())
    }
    
    func test_UrlForAlarmAndMelody_Error() {
        let media = invalidMedia()
        let sut = LocalMediaProvider(melody: media.melody, alarm: media.alarm)
        XCTAssertThrowsError(try sut.alarmUrl())
        XCTAssertThrowsError(try sut.melodyUrl())
    }
    
    //MARK: - Helpers
    
    func validMedia() -> (melody: AudioFile ,alarm: AudioFile) {
        return (AudioFile(name: "melody", extension: "m4a", bundle: Bundle(for: LocalMediaProviderTests.self)),
                AudioFile(name: "alarm", extension: "m4a", bundle: Bundle(for: LocalMediaProviderTests.self)))
    }
    
    func invalidMedia()-> (melody: AudioFile ,alarm: AudioFile) {
        return (AudioFile(name: "melody1", extension: "m4a"),
                AudioFile(name: "alarm1", extension: "m4a"))
    }
    
}
