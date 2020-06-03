//
//  SleepSetupViewModel.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 12.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public struct SleepSetupViewModel {
    
    public enum ViewAction: Equatable {
        case showSettings
        case showDatePicker(viewModel: DatePickerViewModel)
        case showDurationPicker(viewModel: DurationPickerViewModel)
        case showError(message: String)
        case showAlarm(viewModel: AlarmViewModel)
    }
    
    public var settings: Observable<(sleepTimer: SettingViewModel, alarm: SettingViewModel, recording: RecordingSettingModel)> {
        .just((sleepTimer: sleepTimerSetting, alarm: alarmSetting, recording: recordingSetting))
    }
    
    public var mainTitle: Observable<String> {
        interactor.state.filter { [titlesStates] (state) -> Bool in
            return titlesStates.contains(state)
        }.map { (state) in
            self.mainTitle(forState: state)
        }
    }
    
    public var actionTitle: Observable<String> {
        interactor.state.filter { [titlesStates] (state) -> Bool in
            return titlesStates.contains(state)
        }.map { (state) in
            self.actionTitle(forState: state)
        }
    }
    
    public var action: PublishRelay<Void> {
        return interactor.start
    }
    
    public var errorClose: PublishRelay<Void> {
        return interactor.reset
    }
    
    private let errorFormatter: ErrorFormatter
    private let sleepTimerSetting: SettingViewModel
    private let alarmSetting: SettingViewModel
    private let recordingSetting: RecordingSettingModel
    private let interactor: SleepInteractorProtocol
    
    private let permissionsManager: PermissionsManagerProtocol
    
    private var cancel = PublishRelay<Void>()
    private var dateSelected = PublishRelay<Date>()
    private var durationSelected = PublishRelay<Int>()
    private var alarmAccept = PublishRelay<Void>()
    
    private var titlesStates: [SleepInteractorState] = [.initial, .recording, .recordingPause, .recordingPauseByUser, .replay, .replayPause, .replayPauseByUser, .waitingForAlarm, .alarm]
    
    public var viewAction: Observable<ViewAction> {
        Observable.merge(
            alarmSetting.didSelect.flatMap({ [permissionsManager] in
                return permissionsManager.checkNotificationsAllowed()
            }).map({ [dateSelected, cancel] (granted) in
                if granted {
                    return .showDatePicker(viewModel: DatePickerViewModel(dateSelected, cancel: cancel))
                }
                return .showError(message: Constants.NotificationsPermissionsRequired)
            }),
            sleepTimerSetting.didSelect.flatMap({ [permissionsManager] in
                return permissionsManager.checkMicAllowed()
            }).map({ [durationSelected, cancel] (granted) in
                if granted {
                    return .showDurationPicker(viewModel: DurationPickerViewModel(durationSelected, cancel: cancel, options: self.sleepTimeOptions()))
                }
                return .showError(message: Constants.MicroPermissionRequired)
                }),
            dateSelectedAsViewAction(),
            durationSelectedAsViewAction(),
            cancel.map({
                .showSettings
            }),
            recordingSetting.input.flatMap({ [interactor] (enabled) -> Observable<ViewAction> in
                interactor.setRecording(enabled: enabled)
                return .empty()
            }),
            interactorStateAsViewAction()
        )
    }
    
    public init(sleepTimerSetting: SettingViewModel, alarmSetting: SettingViewModel, recordingSetting: RecordingSettingModel, interactor: SleepInteractorProtocol, errorFormatter: ErrorFormatter, permissionsManager: PermissionsManagerProtocol) {
        self.sleepTimerSetting = sleepTimerSetting
        self.alarmSetting = alarmSetting
        self.recordingSetting = recordingSetting
        self.interactor = interactor
        self.errorFormatter = errorFormatter
        self.permissionsManager = permissionsManager
    }
    
    //MARK: - Private
    
    private func durationSelectedAsViewAction() -> Observable<ViewAction> {
        return durationSelected.flatMap({ [interactor] duration in
            return interactor.setSleepTimer(duration: duration)
        }).map({ [sleepTimerSetting] (duration)  in
            if let duration = duration {
                sleepTimerSetting.value.accept(self.sleepTimeOptions()[duration])
            }
            return .showSettings
        })
    }
    
    private func dateSelectedAsViewAction() -> Observable<ViewAction> {
        return dateSelected.flatMap({ [interactor] date in
           return interactor.setAlarm(date: date)
       }).map({ date in
           self.alarmSetting.value.accept(date?.toTimeString())
           return .showSettings
       })
    }
    
    private func interactorStateAsViewAction() -> Observable<ViewAction> {
        return interactor.state.map({ [interactor, errorFormatter] state in
            switch state {
            case .initial:
                self.alarmSetting.value.accept(nil)
                self.sleepTimerSetting.value.accept(nil)
                return .showSettings
            case .error(let error):
                return .showError(message: errorFormatter.description(from: error))
            case .alarm:
                return .showAlarm(viewModel: AlarmViewModel(accept: interactor.reset))
            default:
                return .showSettings
            }
        })
    }
}

extension SleepSetupViewModel {
    public func sleepTimeOptions() -> [Int: String] {
        return [
            0 : "off",
            60 : "1 min",
            300 : "5 min",
            600 : "10 min",
            900 : "15 min",
            1200 : "20 min"
        ]
    }
    
    public func mainTitle(forState: SleepInteractorState) -> String {
        var title = "Idle"
        switch forState {
        case .recording:
            title = "Recording"
        case .recordingPause,
             .recordingPauseByUser:
            title = "Recording Paused"
        case .replay:
            title = "Replay"
        case .replayPause,
             .replayPauseByUser:
            title = "Replay Paused"
        case .waitingForAlarm:
            title = "Waiting for Alarm"
        case .alarm:
            title = "Alarm"
        default:
            break
        }
        return title
    }
    
    public func actionTitle(forState: SleepInteractorState) -> String {
        var title = "Start"
        switch forState {
        case .recording,
             .replay:
            title = "Pause"
        case .recordingPause,
             .recordingPauseByUser,
             .replayPause,
             .replayPauseByUser:
            title = "Resume"
        case .waitingForAlarm:
            title = "Waiting for Alarm"
        case .alarm:
            title = "Alarm"
        default:
            break
        }
        return title
    }
}
