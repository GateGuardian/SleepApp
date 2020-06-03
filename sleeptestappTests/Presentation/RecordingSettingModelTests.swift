//
//  RecordingSettingModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 19.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxRelay
import sleeptestapp

class RecordingSettingModelTests: XCTestCase {
    
    func test_isEqual_Titles() {
        let vm1 = RecordingSettingModel(title: "Foo")
        var vm2 = RecordingSettingModel(title: "Foo")
        vm2.title = "Bar"
        
        XCTAssert(vm1 == vm1)
        XCTAssert(vm1 != vm2)
    }
    
}
