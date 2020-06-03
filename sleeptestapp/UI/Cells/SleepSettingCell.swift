//
//  SleepSettingCell.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 19.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class SleepSettingCell: UITableViewCell {

    public static let identifier: String = "SleepSettingCell"
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var valueLabel: UILabel!
    @IBOutlet public weak var selectionButton: UIButton!
    
    public var viewModel: SettingViewModel? {
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
        viewModel.value.bind(to: valueLabel.rx.text).disposed(by: bag)
        selectionButton.rx.tap.bind(to: viewModel.didSelect).disposed(by: bag)
    }
}


