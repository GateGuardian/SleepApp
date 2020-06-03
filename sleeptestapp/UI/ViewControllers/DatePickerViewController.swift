//
//  DatePickerViewController.swift
//  sleeptestapp
//
//  Created by Ivan Kostromin on 20.05.2020.
//  Copyright © 2020 ik. All rights reserved.
//

import UIKit
import RxRelay
import RxCocoa
import RxSwift

public class DatePickerViewController: UIViewController {
    @IBOutlet public weak var mainTitle: UILabel!
    @IBOutlet public weak var selectButton: UIButton!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var datePicker: UIDatePicker!
    @IBOutlet public weak var pickerContainer: UIView!
    @IBOutlet public weak var shadowContainer: UIView!
    private var shadow: UIView?
    
    public var viewModel: DatePickerViewModel?
    
    private var bag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        setupAppearance(viewModel: viewModel)
        setupActions(viewModel: viewModel)
        shadowContainer.addGestureRecognizer(cancelGesture())
        addShadow()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeShadow()
    }
    
    //MARK: - Private
    
    private func setupAppearance(viewModel: DatePickerViewModel) {
        pickerContainer.layer.cornerRadius = 8.0
        mainTitle.text = viewModel.title
        selectButton.setTitle(viewModel.selectTitle, for: .normal)
        cancelButton.setTitle(viewModel.cancelTitle, for: .normal)
    }
    
    private func setupActions(viewModel: DatePickerViewModel) {
        selectButton.rx.tap.bind { [weak datePicker] (_) in
            guard let datePicker = datePicker else { return }
            viewModel.didSelectDate.accept(datePicker.date)
        }.disposed(by: bag)
        cancelButton.rx.tap.bind(to: viewModel.cancel).disposed(by: bag)
    }
    
    private func removeShadow() {
        UIView.animate(withDuration: 0.3, animations: {
            self.shadow?.alpha = 0.0
        }) { (_) in
            self.shadow?.removeFromSuperview()
            self.shadow = nil
        }
    }
    
    private func addShadow() {
        let container = shadowContainerView()
        let shadow = createShadowView()
        container.addSubviewWithConstraints(shadow)
        UIView.animate(withDuration: 0.3) {
            shadow.alpha = 0.25
        }
        self.shadow = shadow
    }
    
    private func shadowContainerView() -> UIView {
        var result: UIView = shadowContainer
        if let presentingView = presentingViewController?.view {
            result = presentingView
        }
        return result
    }
    
    private func createShadowView() -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }
    
    private func cancelGesture() -> UITapGestureRecognizer {
        let recognizer = UITapGestureRecognizer()
        if let viewModel = viewModel {
            recognizer.rx.event.flatMap { (_) -> Observable<Void> in
                return .just(())
            }.bind(to: viewModel.cancel).disposed(by: bag)
        }
        return recognizer
    }
}

extension UIView {
    func addSubviewWithConstraints(_ subview: UIView) {
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: self.topAnchor),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
