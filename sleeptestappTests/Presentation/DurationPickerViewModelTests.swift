//
//  DurationPickerViewModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 13.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxRelay
import sleeptestapp

class DurationPickerViewModelTests: XCTestCase {
    
    func test_isEqual_Titles() {
        let vm1 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [0 : "off"])
        var vm2 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [0 : "off"])
        vm2.title = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_CancelTitles() {
        let vm1 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [0 : "off"])
        var vm2 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [0 : "off"])
        vm2.cancelTitle = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_DurationOptions() {
        let vm1 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [12000 : "too looong"])
        let vm2 = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: [0 : "off"])
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    
}


