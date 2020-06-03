//
//  RecordingSettingCell.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 20.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class RecordingSettingCell: UITableViewCell {

    public static let identifier: String = "RecordingSettingCell"
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var recordSwitch: UISwitch!
    
    public var viewModel: RecordingSettingModel? {
        didSet {
            setup()
        }
    }
    
    private var bag = DisposeBag()
    
    public override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    //MARK: - Private
    
    private func setup() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        recordSwitch.rx.isOn.bind(to: viewModel.input).disposed(by: bag)
    }
    
}
