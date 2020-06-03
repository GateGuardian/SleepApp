//
//  AlarmViewModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 19.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxRelay
import sleeptestapp

class AlarmViewModelTests: XCTestCase {
    
    func test_isEqual_Titles() {
        let vm1 = AlarmViewModel(accept: PublishRelay<Void>())
        var vm2 = AlarmViewModel(accept: PublishRelay<Void>())
        vm2.title = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_StopTitles() {
        let vm1 = AlarmViewModel(accept: PublishRelay<Void>())
        var vm2 = AlarmViewModel(accept: PublishRelay<Void>())
        vm2.stopTitle = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
    func test_isEqual_Messages() {
        let vm1 = AlarmViewModel(accept: PublishRelay<Void>())
        var vm2 = AlarmViewModel(accept: PublishRelay<Void>())
        vm2.message = "another"
        
        XCTAssertEqual(vm1, vm1)
        XCTAssertNotEqual(vm1, vm2)
    }
    
}
