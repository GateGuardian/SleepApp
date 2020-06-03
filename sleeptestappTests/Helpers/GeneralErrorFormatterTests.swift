//
//  GeneralErrorFormatterTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 26.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import sleeptestapp

class GeneralErrorFormatterTests: XCTestCase {
    
    func test_LocalizedError_WithDescription() {
        
        struct DummyError: LocalizedError {
            public var errorDescription: String? {
                return "Dummy"
            }
        }
        
        let sut = GeneralErrorFormatter()
        let message = sut.description(from: DummyError())
        XCTAssertEqual(message, DummyError().errorDescription)
    }
    
    func test_LocalizedError_WithNoDescription() {
        
        struct DummyError: LocalizedError {
            public var errorDescription: String? {
                return nil
            }
        }
        let sut = GeneralErrorFormatter()
        let message = sut.description(from: DummyError())
        XCTAssertNotEqual(message, DummyError().errorDescription)
        let error = DummyError() as Error
        XCTAssertEqual(message, error.localizedDescription)
    }
}
