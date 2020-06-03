//
//  SleepSetupViewController.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 19.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

public class SleepSetupViewController: UIViewController {
    
    typealias Section = AnimatableSectionModel<String, SleepSettingCellModel>
    
    public var viewModel: SleepSetupViewModel?
    @IBOutlet public var tableView: UITableView!
    @IBOutlet public var mainTitleLabel: UILabel!
    @IBOutlet public var actionButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Move to separate entity
        registerCells()
        guard let viewModel = viewModel else { return }
        viewModel.mainTitle.bind(to: mainTitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.actionTitle.bind(to: actionButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewActoinBinding(viewModel: viewModel)
        actionButtonSetup(viewModel: viewModel)
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(configureCell:{ (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case let .alarm(vm):
                let cell = tableView.dequeueReusableCell(withIdentifier: SleepSettingCell.identifier, for: indexPath) as! SleepSettingCell
                cell.viewModel = vm
                return cell
            case let .recording(vm):
                let cell = tableView.dequeueReusableCell(withIdentifier: RecordingSettingCell.identifier, for: indexPath) as! RecordingSettingCell
                cell.viewModel = vm
                return cell
            case let .sleepTimer(vm):
                let cell = tableView.dequeueReusableCell(withIdentifier: SleepSettingCell.identifier, for: indexPath) as! SleepSettingCell
                cell.viewModel = vm
                return cell
            }
        })
        let sections: Observable<[Section]> = viewModel.settings.map { settings in
            let items = [
                SleepSettingCellModel.sleepTimer(settings.sleepTimer),
                SleepSettingCellModel.alarm(settings.alarm),
                SleepSettingCellModel.recording(settings.recording)
            ]
            return [
                AnimatableSectionModel(model: "Settings", items: items)
            ]
        }
        sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

    //MARK: - Private
    
    private func registerCells() {
        var nib = UINib(nibName: SleepSettingCell.identifier, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: SleepSettingCell.identifier)
        nib = UINib(nibName: RecordingSettingCell.identifier, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: RecordingSettingCell.identifier)
    }
    
    private func viewActoinBinding(viewModel: SleepSetupViewModel) {
        viewModel.viewAction.asDriver(onErrorJustReturn: .showSettings).drive(onNext: {[weak self]  (action) in
//            print("SleepSetupViewController \(action)")
            self?.presentedViewController?.dismiss(animated: true, completion: nil)
            switch action {
            case let .showDatePicker(datePickerViewModel):
                self?.showDatePicker(viewModel: datePickerViewModel)
            case let .showDurationPicker(durationPickerViewModel):
                self?.showDurationPicker(viewModel: durationPickerViewModel)
            case let .showError(message):
                self?.showError(message: message)
            case let .showAlarm(alarmViewModel):
                self?.showAlarm(viewModel: alarmViewModel)
            case .showSettings:
                self?.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
    }
    
    private func actionButtonSetup(viewModel: SleepSetupViewModel) {
        actionButton.layer.cornerRadius = 8.0
        actionButton.rx.tap.bind(to: viewModel.action).disposed(by: disposeBag)
    }
    
    private func showDatePicker(viewModel: DatePickerViewModel) {
        let vc: DatePickerViewController = UIStoryboard.init(.main).instantiateViewController()
        vc.viewModel = viewModel
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    private func showDurationPicker(viewModel: DurationPickerViewModel) {
        let actionSheet = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .actionSheet)
        for (value, title) in viewModel.sortedOptions {
            actionSheet.addAction(
                UIAlertAction(title: title, style: .default) { (_) in
                        viewModel.didSelectDuration.accept(value)
                }
            )
        }
        actionSheet.addAction(UIAlertAction(title: viewModel.cancelTitle, style: .cancel) { (_) in
            viewModel.cancel.accept(())
        })
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [viewModel] (_) in
            viewModel?.errorClose.accept(())
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlarm(viewModel: AlarmViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: viewModel.stopTitle, style: .cancel, handler: { (_) in
            viewModel.stop.accept(())
        }))
        present(alert, animated: true, completion: nil)
    }
}

