//
//  DatePickerViewControllerTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 28.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxRelay
import RxSwift
import sleeptestapp

class DatePickerViewControllerTests: XCTestCase {
    var dispooseBag = DisposeBag()
    
    func test_Appearance() {
        let (sut, vm) = makeSUT()
        XCTAssertEqual(vm.title, sut.mainTitle.text)
        XCTAssertEqual(vm.selectTitle, sut.selectButton.title(for: .normal))
        XCTAssertEqual(vm.cancelTitle, sut.cancelButton.title(for: .normal))
    }
    
    func test_DateSelection() {
        let (sut, vm) = makeSUT()
        let spy = Spy<Date>(observable: vm.didSelectDate.asObservable())
        sut.selectButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(spy.values, [sut.datePicker.date])
    }
    
    func test_Cancel() {
        var didCancel = false
        let (sut, vm) = makeSUT()
        vm.cancel.subscribe(onNext: { (_) in
            didCancel = true
        }).disposed(by: dispooseBag)
        sut.cancelButton.sendActions(for: .touchUpInside)
        XCTAssert(didCancel)
        dispooseBag = DisposeBag()
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> (sut: DatePickerViewController, vm: DatePickerViewModel)  {
        let vm = DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>())
        let storyboard = UIStoryboard(.main)
        let vc: DatePickerViewController = storyboard.instantiateViewController()
        vc.viewModel = vm
        let window = UIWindow()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        _ = vc.view
        return (vc, vm)
    }
}
