//
//  SleepSetupViewControllerTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 13.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import XCTest
import sleeptestapp


class SleepSetupViewControllerTests: XCTestCase {
    
    /*TODO:
     - Settings
     - View Actions
     - Titles
     */
    
    func test_Settings() throws {
        
        let (sut, vm) = makeSUT()
        let vmSetttingsSpy = CurrentValueSpy<(sleepTimer: SettingViewModel, alarm: SettingViewModel, recording: RecordingSettingModel)>(observable: vm.settings)
        
        guard let settings = vmSetttingsSpy.current else {
            return XCTFail("Expecting Settings in SleepSetupViewModel")
        }
        XCTAssertEqual(sut.tableView.numberOfRows(inSection:0), Mirror(reflecting: settings).children.count)
        let firstSettingCell = try XCTUnwrap(sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        XCTAssert(firstSettingCell.isKind(of: SleepSettingCell.self))
        let secondSettingCell = try XCTUnwrap(sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0)))
        XCTAssert(secondSettingCell.isKind(of: SleepSettingCell.self))
        let thirdSettingCell = try XCTUnwrap(sut.tableView.cellForRow(at: IndexPath(row: 2, section: 0)))
        XCTAssert(thirdSettingCell.isKind(of: RecordingSettingCell.self))
    }
    
    //MARK: - Main Title
    
    func test_MainTitle_Changes() throws {
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)

        let expectedTitles = [
            vm.mainTitle(forState: .initial),
            vm.mainTitle(forState: .replay),
            vm.mainTitle(forState: .replayPause),
            vm.mainTitle(forState: .replayPauseByUser),
            vm.mainTitle(forState: .recording),
            vm.mainTitle(forState: .recordingPause),
            vm.mainTitle(forState: .recordingPauseByUser)
        ]
        var mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        var actualTitles = [mainTitle]
        interactor.state.accept(.replay)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)
        interactor.state.accept(.replayPause)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)
        interactor.state.accept(.replayPauseByUser)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)
        interactor.state.accept(.recording)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)
        interactor.state.accept(.recordingPause)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)
        interactor.state.accept(.recordingPauseByUser)
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)

        XCTAssertEqual(actualTitles, expectedTitles)
    }
    
    func test_MainTitle_ChangesNot() throws {
        
        struct DummyLocalizedError: LocalizedError {
            var errorDescription: String? {
                return nil
            }
        }
        
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)

        let expectedTitles = [
            vm.mainTitle(forState: .initial),
            vm.mainTitle(forState: .initial)
        ]
        var mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        var actualTitles = [mainTitle]
        interactor.state.accept(.error(DummyLocalizedError()))
        mainTitle = try XCTUnwrap(sut.mainTitleLabel.text)
        actualTitles.append(mainTitle)

        XCTAssertEqual(actualTitles, expectedTitles)
    }
    
    //MARK: - Action Title
    
    func test_ActionTitle_Changes() throws {
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)

        let expectedTitles = [
            vm.actionTitle(forState: .initial),
            vm.actionTitle(forState: .replay),
            vm.actionTitle(forState: .replayPause),
            vm.actionTitle(forState: .replayPauseByUser),
            vm.actionTitle(forState: .recording),
            vm.actionTitle(forState: .recordingPause),
            vm.actionTitle(forState: .recordingPauseByUser)
        ]
        
        var actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        var actualTitles = [actionTitle]
        interactor.state.accept(.replay)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)
        interactor.state.accept(.replayPause)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)
        interactor.state.accept(.replayPauseByUser)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)
        interactor.state.accept(.recording)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)
        interactor.state.accept(.recordingPause)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)
        interactor.state.accept(.recordingPauseByUser)
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)

        XCTAssertEqual(actualTitles, expectedTitles)
    }
    
    func test_ActionTitle_ChangesNot() throws {
        
        struct DummyLocalizedError: LocalizedError {
            var errorDescription: String? {
                return nil
            }
        }
        
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)

        let expectedTitles = [
            vm.actionTitle(forState: .initial),
            vm.actionTitle(forState: .initial)
        ]
        var actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        var actualTitles = [actionTitle]
        interactor.state.accept(.error(DummyLocalizedError()))
        actionTitle = try XCTUnwrap(sut.actionButton.title(for: .normal))
        actualTitles.append(actionTitle)

        XCTAssertEqual(actualTitles, expectedTitles)
    }
    
    //MARK: - Pickers
    
    func test_ShowDatePicker() {
        let (sut, vm) = makeSUT()
        let vmSetttingsSpy = CurrentValueSpy<(sleepTimer: SettingViewModel, alarm: SettingViewModel, recording: RecordingSettingModel)>(observable: vm.settings)
        vmSetttingsSpy.current?.alarm.didSelect.accept(())
        let expect = expectation(description: "Presenting Picker")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        let pickerVC = sut.presentedViewController as? DatePickerViewController
        XCTAssertNotNil(pickerVC)
        XCTAssertNotNil(pickerVC?.viewModel)
    }
    
    func test_ShowDurationPicker() {
        let (sut, vm) = makeSUT()
        let vmSetttingsSpy = CurrentValueSpy<(sleepTimer: SettingViewModel, alarm: SettingViewModel, recording: RecordingSettingModel)>(observable: vm.settings)
        vmSetttingsSpy.current?.sleepTimer.didSelect.accept(())
        let expect = expectation(description: "Presenting Picker")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertNotNil(sut.presentedViewController as? UIAlertController)
    }
    
    //MARK: - Error Alert
    
    func test_ShowErrorAlert() throws {
        let error = SleepSetupValidationError.alarmNotSet
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, _) = makeSUT(interactor: interactor)
        
        sut.actionButton.sendActions(for: .touchUpInside)
        
        let expect = expectation(description: "Presenting Error")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        let alert = try XCTUnwrap(sut.presentedViewController as? UIAlertController)
        
        XCTAssertEqual(alert.message, error.errorDescription)
    }
    
    //MARK: - Alarm
    
    func test_ShowAlarmAlert() throws {
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)
        interactor.state.accept(.alarm)
        let spy = CurrentValueSpy<SleepSetupViewModel.ViewAction>(observable: vm.viewAction)
        let alarmViewModel = try XCTUnwrap(spy.alarmViewModel())
        
        let expect = expectation(description: "Presenting Alarm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        let alert = try XCTUnwrap(sut.presentedViewController as? UIAlertController)
        
        XCTAssertEqual(alert.title, alarmViewModel.title)
    }
    
    func test_ShowSettings_After_ShowAlarmAlert() throws {
        let interactor = SleepInteractorStub()
        let (sut, vm) = makeSUT(interactor: interactor)
        interactor.state.accept(.alarm)
        let spy = CurrentValueSpy<SleepSetupViewModel.ViewAction>(observable: vm.viewAction)
        
        let alarmViewModel = try XCTUnwrap(spy.alarmViewModel())
        alarmViewModel.stop.accept(())
        
        let expect = expectation(description: "Removing Alarm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNil(sut.presentedViewController)
    }
    
    //MARK: - Helpers
    
    func makeSUT(interactor: SleepInteractorProtocol = SleepInteractorStub()) -> (sut: SleepSetupViewController, vm: SleepSetupViewModel)  {
        
        let sleepTimerSetting = SettingViewModel(title: "Sleep Timer")
        let alarmSetting = SettingViewModel(title: "Alarm")
        let recordingSetting = RecordingSettingModel(title: "Allow recording")
        
        let vm = SleepSetupViewModel(sleepTimerSetting: sleepTimerSetting, alarmSetting: alarmSetting, recordingSetting: recordingSetting, interactor: interactor, errorFormatter: GeneralErrorFormatter(), permissionsManager: PermissionsManagerStub())
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: "SleepSetupViewController") as! SleepSetupViewController
        vc.viewModel = vm
        
        let window = UIWindow()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        _ = vc.view
        return (vc, vm)
    }
    
}

class CurrentValueSpy<T> {
    
    private(set) var current: T?
    private let bag = DisposeBag()
    
    init(observable: Observable<T>) {
        observable.subscribe(onNext: {[weak self] value in
            self?.current = value
            }).disposed(by: bag)
    }
}

extension CurrentValueSpy where T == SleepSetupViewModel.ViewAction {
    func alarmViewModel() -> AlarmViewModel? {
        if let action = current, case let SleepSetupViewModel.ViewAction.showAlarm(viewModel) = action {
            return viewModel
        }
        return nil
    }
}
