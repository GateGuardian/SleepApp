//
//  SleepSetupViewModelTests.swift
//  sleeptestappTests
//
//  Created by Ivan Kostromin on 05.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxCocoa
import sleeptestapp

class SleepSetupViewModelTests: XCTestCase {
    
    func test_Settings() throws {
        let (sut, settings, _) = makeSUT()
        let settingsSpy = Spy<(sleepTimer: SettingViewModel, alarm: SettingViewModel, recording: RecordingSettingModel)>(observable: sut.settings)
        let spySettings = try XCTUnwrap(settingsSpy.values.last)
        
        XCTAssert(spySettings == settings)
    }
    
    func test_ShowSettingsAction() {
        let (sut, _, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        XCTAssertEqual(actionSpy.values, [.showSettings])
    }
    
    func test_ShowDatePickerAction() {
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        settings.alarmSetting.didSelect.accept(())
        
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDatePicker(viewModel: DatePickerViewModel(PublishRelay<Date>(), cancel: PublishRelay<Void>()))])
    }
    
    func test_ShowDurationPickerAction() {
        
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        settings.sleepTimerSetting.didSelect.accept(())
        let durationPickerVM = DurationPickerViewModel(PublishRelay<Int>(), cancel: PublishRelay<Void>(), options: sut.sleepTimeOptions())
        
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDurationPicker(viewModel: durationPickerVM)])
    }
    
    func test_DateValueSelected_And_ShowSettingsAction() throws {
        
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        let dateValueSpy = Spy<String?>(observable: settings.alarmSetting.value.asObservable())
        settings.alarmSetting.didSelect.accept(())
        
        let datePickerVM = try XCTUnwrap(actionSpy.values.last?.datePicker, "Expecting DatePickerViewModel in current action")
        let date = Date()
        let dateString = date.toTimeString()
        datePickerVM.didSelectDate.accept(date)
        
        XCTAssertEqual(dateValueSpy.values, [nil, dateString])
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDatePicker(viewModel: datePickerVM), .showSettings])
    }
    
    func test_DurationValueSelected_And_ShowSettingsAction() throws {
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        let durationValueSpy = Spy<String?>(observable: settings.sleepTimerSetting.value.asObservable())
        settings.sleepTimerSetting.didSelect.accept(())
        
        let offOption = try XCTUnwrap(sut.sleepTimeOptions().first, "Expecting SleepTImeOptions to be not empty")
        let durationPickerVM = try XCTUnwrap(actionSpy.values.last?.durationPicker, "Expecting DurationPickerViewModel in current action")
       
        durationPickerVM.didSelectDuration.accept(offOption.key)
        
        XCTAssertEqual(durationValueSpy.values, [nil, offOption.value])
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDurationPicker(viewModel: durationPickerVM), .showSettings])
    }
    
    //MARK: - Permissions Denied
    
    func test_ShowPermissonAlert_NotificationsNotAllowed() {
        let (sut, settings, permissionsManager) = makeSUT()
        permissionsManager.notificationsAllowed = false
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        settings.alarmSetting.didSelect.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showError(message: Constants.NotificationsPermissionsRequired)])
    }
    
    func test_ShowPermissonAlert_MicroUsageNotAllowed() {
        let (sut, settings, permissionsManager) = makeSUT()
        permissionsManager.micAllowed = false
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        settings.sleepTimerSetting.didSelect.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showError(message: Constants.MicroPermissionRequired)])
    }
    
    //MARK: - Cancel
    
    func test_ShowSettingsAction_After_DateSelectionCancel() throws {
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        settings.alarmSetting.didSelect.accept(())
        
        let datePickerVM = try XCTUnwrap(actionSpy.values.last?.datePicker, "Expecting DatePickerViewModel in current action")
        datePickerVM.cancel.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDatePicker(viewModel: datePickerVM), .showSettings])
    }
    
    func test_ShowSettingsAction_After_DurationSelectionCancel() throws {
        let (sut, settings, _) = makeSUT()
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        settings.sleepTimerSetting.didSelect.accept(())
        
        let durationPickerVM = try XCTUnwrap(actionSpy.values.last?.durationPicker, "Expecting DurationPickerViewModel in current action")
        durationPickerVM.cancel.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDurationPicker(viewModel: durationPickerVM), .showSettings])
    }
    
    //MARK: - Errors
    
    func test_ShowErrorAction_AlarmAndSleepTimerIntersect_AfterDateSelection() throws {
        let error = SleepSetupValidationError.alarmAndSleepTimerIntersect
        let errorMessage = try XCTUnwrap(error.errorDescription, "Expecting Localized Error Description")
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, settings, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        settings.alarmSetting.didSelect.accept(())
        
        let datePickerVM = try XCTUnwrap(actionSpy.values.last?.datePicker, "Expecting DatePickerViewModel in current action")
        
        datePickerVM.didSelectDate.accept(Date())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDatePicker(viewModel: datePickerVM), .showError(message: errorMessage)])
    }
    
    func test_ShowErrorAction_AlarmAndSleepTimerIntersect_AfterDurationSelection() throws {
        let error = SleepSetupValidationError.alarmAndSleepTimerIntersect
        let errorMessage = try XCTUnwrap(error.errorDescription, "Expecting Localized Error Description")
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, settings, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        settings.sleepTimerSetting.didSelect.accept(())
        
        let offOption = try XCTUnwrap(sut.sleepTimeOptions().first, "Expecting SleepTImeOptions to be not empty")
        let durationPickerVM = try XCTUnwrap(actionSpy.values.last?.durationPicker, "Expecting DurationPickerViewModel in current action")
        
        durationPickerVM.didSelectDuration.accept(offOption.key)
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDurationPicker(viewModel: durationPickerVM), .showError(message: errorMessage)])
    }
    
    func test_ShowErrorAction_AlarmSetInPast() throws {
        let error = SleepSetupValidationError.alarmSetInPast
        let errorMessage = try XCTUnwrap(error.errorDescription, "Expecting Localized Error Description")
        
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, settings, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        settings.sleepTimerSetting.didSelect.accept(())
        
        let offOption = try XCTUnwrap(sut.sleepTimeOptions().first, "Expecting SleepTImeOptions to be not empty")
        let durationPickerVM = try XCTUnwrap(actionSpy.values.last?.durationPicker, "Expecting DurationPickerViewModel in current action")
        
        durationPickerVM.didSelectDuration.accept(offOption.key)
        XCTAssertEqual(actionSpy.values, [.showSettings, .showDurationPicker(viewModel: durationPickerVM), .showError(message: errorMessage)])
    }
    
    func test_ShowErrorAction_AlarmNotSet_AfterStartAction() throws {
        let error = SleepSetupValidationError.alarmNotSet
        let errorMessage = try XCTUnwrap(error.errorDescription, "Expecting Localized Error Description")
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        sut.action.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showError(message: errorMessage)])
    }
    
    func test_ShowErrorAction_SleepTimerDurationNotSet_AfterStartAction() throws {
        let error = SleepSetupValidationError.sleepTimerDurationNotSet
        let errorMessage = try XCTUnwrap(error.errorDescription, "Expecting Localized Error Description")
        let interactor = SleepInteractorErrorStub(error: error)
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        sut.action.accept(())
        XCTAssertEqual(actionSpy.values, [.showSettings, .showError(message: errorMessage)])
    }
    
    func test_ShowErrorAction_LocalizedDescription() throws {
        struct DummyLocalizedError: LocalizedError {
            var errorDescription: String? {
                return nil
            }
        }
        
        let interactor = SleepInteractorStub()
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        let dummyError = DummyLocalizedError() as Error
        
        interactor.state.accept(SleepInteractorState.error(dummyError))
        XCTAssertEqual(actionSpy.values, [.showSettings, .showError(message: dummyError.localizedDescription)])
    }
    
    //MARK: - Titles
    
    func test_MainTitle_Initial() {
        let (sut, _, _) = makeSUT()
        let mainTitleSpy = Spy<String>(observable: sut.mainTitle)
        let title = sut.mainTitle(forState: SleepInteractorState.initial)
        XCTAssertEqual(mainTitleSpy.values, [title])
    }
    
    func test_MainTitle_AllStates() {
        let interactor = SleepInteractorStub()
        let (sut, _, _) = makeSUT(interactor: interactor)
        let mainTitleSpy = Spy<String>(observable: sut.mainTitle)
        let titles = [
            sut.mainTitle(forState: SleepInteractorState.initial),
            sut.mainTitle(forState: SleepInteractorState.replay),
            sut.mainTitle(forState: SleepInteractorState.replayPause),
            sut.mainTitle(forState: SleepInteractorState.replayPauseByUser),
            sut.mainTitle(forState: SleepInteractorState.recording),
            sut.mainTitle(forState: SleepInteractorState.recordingPause),
            sut.mainTitle(forState: SleepInteractorState.recordingPauseByUser),
            sut.mainTitle(forState: .waitingForAlarm)
        ]
        
        interactor.state.accept(.replay)
        interactor.state.accept(.replayPause)
        interactor.state.accept(.replayPauseByUser)
        interactor.state.accept(.recording)
        interactor.state.accept(.recordingPause)
        interactor.state.accept(.recordingPauseByUser)
        interactor.state.accept(.waitingForAlarm)
        
        XCTAssertEqual(mainTitleSpy.values, titles)
    }
    
    func test_ActionTitle_Initial() {
        let (sut, _, _) = makeSUT()
        let mainTitleSpy = Spy<String>(observable: sut.actionTitle)
        let title = sut.actionTitle(forState: SleepInteractorState.initial)
        XCTAssertEqual(mainTitleSpy.values, [title])
    }
    
    func test_ActionTitle_AllStates() {
        let interactor = SleepInteractorStub()
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionTitleSpy = Spy<String>(observable: sut.actionTitle)
        let titles = [
            sut.actionTitle(forState: SleepInteractorState.initial),
            sut.actionTitle(forState: SleepInteractorState.replay),
            sut.actionTitle(forState: SleepInteractorState.replayPause),
            sut.actionTitle(forState: SleepInteractorState.replayPauseByUser),
            sut.actionTitle(forState: SleepInteractorState.recording),
            sut.actionTitle(forState: SleepInteractorState.recordingPause),
            sut.actionTitle(forState: SleepInteractorState.recordingPauseByUser),
            sut.actionTitle(forState: .waitingForAlarm)
        ]
        
        interactor.state.accept(.replay)
        interactor.state.accept(.replayPause)
        interactor.state.accept(.replayPauseByUser)
        interactor.state.accept(.recording)
        interactor.state.accept(.recordingPause)
        interactor.state.accept(.recordingPauseByUser)
        interactor.state.accept(.waitingForAlarm)
        
        XCTAssertEqual(actionTitleSpy.values, titles)
    }
    
    func test_ShowSettingsAction_WithAudioRelatedInteractorState() {
        let interactor = SleepInteractorStub()
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        let actions: [SleepSetupViewModel.ViewAction] = [
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings,
            SleepSetupViewModel.ViewAction.showSettings
        ]
        
        interactor.state.accept(.replay)
        interactor.state.accept(.replayPause)
        interactor.state.accept(.replayPauseByUser)
        interactor.state.accept(.recording)
        interactor.state.accept(.recordingPause)
        interactor.state.accept(.recordingPauseByUser)
        
        XCTAssertEqual(actionSpy.values, actions)
    }
    
    //MARK: - Alarm
    
    func test_ShowAlarmAction() {
        let interactor = SleepInteractorStub()
        let (sut, _, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        
        interactor.state.accept(.alarm)
        
        XCTAssertEqual(actionSpy.values, [.showSettings, .showAlarm(viewModel: AlarmViewModel(accept: PublishRelay<Void>()))])
    }
    
    func test_Reset_AfterAlarmAccept() throws {
        let interactor = SleepInteractorStub()
        let (sut, settings, _) = makeSUT(interactor: interactor)
        let actionSpy = Spy<SleepSetupViewModel.ViewAction>(observable: sut.viewAction)
        let alarmSettingSpy = Spy<String?>(observable: settings.alarmSetting.value.asObservable())
        let sleepSettingSpy = Spy<String?>(observable: settings.sleepTimerSetting.value.asObservable())
        let mainTitleSpy = Spy<String>(observable: sut.mainTitle)
        let actionTitleSpy = Spy<String>(observable: sut.actionTitle)
        
        let alarmSettingValues: [String?] = [nil, nil]
        let sleepSettingValues: [String?] = [nil, nil]
        let mainTitles: [String] = [sut.mainTitle(forState: SleepInteractorState.initial), sut.mainTitle(forState: .alarm), sut.mainTitle(forState: SleepInteractorState.initial)]
        let actionTiles: [String] = [sut.actionTitle(forState: SleepInteractorState.initial), sut.actionTitle(forState: .alarm), sut.actionTitle(forState: SleepInteractorState.initial)]
        
        interactor.state.accept(.alarm)
        let alarmViewModel = try XCTUnwrap(actionSpy.values.last?.alarmViewModel, "Expecting AlarmViewModel in current action")
        alarmViewModel.stop.accept(())
        XCTAssertEqual(alarmSettingSpy.values, alarmSettingValues)
        XCTAssertEqual(sleepSettingSpy.values, sleepSettingValues)
        XCTAssertEqual(mainTitleSpy.values, mainTitles)
        XCTAssertEqual(actionTitleSpy.values, actionTiles)
        XCTAssertEqual(actionSpy.values, [.showSettings, .showAlarm(viewModel: alarmViewModel), .showSettings])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(interactor: SleepInteractorProtocol = SleepInteractorStub()) -> (
        sut: SleepSetupViewModel,
        settingsModels: (
            sleepTimerSetting: SettingViewModel,
            alarmSetting: SettingViewModel,
            recordingSetting: RecordingSettingModel
            ),
        permissionsManager: PermissionsManagerStub
    ) {
        let sleepTimerSetting = SettingViewModel(title: "Sleep Timer")
        let alarmSetting = SettingViewModel(title: "Alarm")
        let recordingSetting = RecordingSettingModel(title: "Allow recording")
        let permissionsManager = PermissionsManagerStub()
        
        let sut = SleepSetupViewModel(sleepTimerSetting: sleepTimerSetting, alarmSetting: alarmSetting, recordingSetting: recordingSetting, interactor: interactor, errorFormatter: GeneralErrorFormatter(), permissionsManager: permissionsManager)
        return (sut, (sleepTimerSetting, alarmSetting, recordingSetting), permissionsManager)
    }
}


class Spy<T> {
    private(set) var values: [T] = []
    private let bag = DisposeBag()
    
    init(observable: Observable<T>) {
        observable.subscribe(onNext: {[weak self] value in
            self?.values.append(value)
            }).disposed(by: bag)
    }
}

class PermissionsManagerStub: PermissionsManagerProtocol {
    
    var notificationsAllowed: Bool = true
    var micAllowed: Bool = true
    
    func checkNotificationsAllowed() -> Observable<Bool> {
        return .just(notificationsAllowed)
    }
    
    func checkMicAllowed() -> Observable<Bool> {
        return .just(micAllowed)
    }
}

private extension SleepSetupViewModel.ViewAction {
    var datePicker: DatePickerViewModel? {
        switch self {
        case let .showDatePicker(datePicker):
            return datePicker
        default:
            return nil
        }
    }

    var durationPicker: DurationPickerViewModel? {
        switch self {
        case let .showDurationPicker(durationPicker):
            return durationPicker
        default:
            return nil
        }
    }
    
    var alarmViewModel: AlarmViewModel? {
        
        switch self {
        case let .showAlarm(viewModel):
            return viewModel
        default:
            return nil
        }
    }
}

