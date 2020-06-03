//
//  DependencyContainer.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 28.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import AVFoundation

struct DependencyContainer {
    let rootViewController: SleepSetupViewController
    
    static func Default() -> DependencyContainer {
        let storyboard = UIStoryboard.init(.main)
        let vc: SleepSetupViewController = storyboard.instantiateViewController()
        vc.viewModel = createViewModel()
        return DependencyContainer(rootViewController: vc)
    }
    
    private static func createViewModel() -> SleepSetupViewModel {
        let interactor = createInteractor()
        return SleepSetupViewModel(sleepTimerSetting: SettingViewModel(title: "Sleep Timer"), alarmSetting: SettingViewModel(title: "Alarm"), recordingSetting: RecordingSettingModel(title: "Recording"), interactor: interactor, errorFormatter: GeneralErrorFormatter(), permissionsManager: PermissionManager())
    }
    
    private static func createInteractor() -> SleepInteractorProtocol {
        let dateValidator = DateValidator()
        let intersectionValidator = IntersectionValidator()
        let sleepValidator = SleepSetupValidator(dateValidator: dateValidator, intersectionValidator: intersectionValidator)
        
        let melodyFile = AudioFile(name: "nature", extension: "m4a")
        let alarmFile = AudioFile(name: "alarm", extension: "m4a")
        let mediaProvider = LocalMediaProvider(melody: melodyFile, alarm: alarmFile)
        guard let melodyUrl = try? mediaProvider.melodyUrl(), let alarmUrl = try? mediaProvider.alarmUrl() else {
            fatalError("Failed to get Melody File URL and/or Alarm File URL")
        }
        let audionEngine = AVAudioEngine()
        let recorder = AudioRecorder(audioEngine: audionEngine)
        let melodyPlayer = AudioDurationalPlayer(player: AudioPlayer(audioEngine: audionEngine, fileUrl: melodyUrl))
        let alarmPlayer = AudioPlayer(audioEngine: audionEngine, fileUrl: alarmUrl)
        
        
        let alarmScheduler = AlarmScheduler()
        let sessionConfigurator = SessionConfigurator()
        
        return SleepInteractor(startValidator: sleepValidator, alarmValidator: dateValidator, intersectionValidator: intersectionValidator, melodyPlayer: melodyPlayer, recorder: recorder, mediaProvider: mediaProvider, alarmPlayer: alarmPlayer, alarmScheduler: alarmScheduler, sessionConfigurator: sessionConfigurator)
    }
}
