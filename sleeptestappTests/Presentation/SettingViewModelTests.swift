//
//  SettingViewModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 13.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import sleeptestapp

class SettingViewModelTests: XCTestCase {
    
    func test_isEqual_Titles() {
        let s1 = SettingViewModel(title: "title")
        let s2 = SettingViewModel(title: "another title")
        
        XCTAssert(s1 == s1)
        XCTAssert(s1 != s2)
    }
    
}
