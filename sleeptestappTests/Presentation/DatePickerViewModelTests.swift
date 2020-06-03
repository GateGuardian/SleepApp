//
//  DatePickerViewModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 13.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxRelay
import sleeptestapp

class DatePickerViewModelTests: XCTestCase {
    
    func test_isEqual_Titles() {
        let vm1 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        var vm2 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        vm2.title = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_CacnelTitles() {
        let vm1 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        var vm2 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        vm2.cancelTitle = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_SelectTitles() {
        let vm1 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        var vm2 = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        vm2.selectTitle = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
}
