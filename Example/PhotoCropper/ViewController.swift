//
//  ViewController.swift
//  PhotoCropper_Example
//
//  Created by Aaron Lee on 2021/12/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import PhotoCropper
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

class ViewController: UIViewController {
  private var bag = DisposeBag()

  private let stackView = UIStackView()
    .then {
      $0.axis = .vertical
      $0.spacing = 16
      $0.alignment = .fill
      $0.distribution = .fill
    }

  private let ratioButton = UIButton(type: .system)
    .then {
      $0.setTitle("Restricted Ratio", for: .normal)
    }

  private let customizableButton = UIButton(type: .system)
    .then {
      $0.setTitle("Customizable", for: .normal)
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    layoutView()
    bindRx()
  }
}

// MARK: - Configure

extension ViewController {
  private func configureView() {
    title = "PhotoCropper Examples"

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    view.addSubview(stackView)
    stackView.addArrangedSubview(ratioButton)
    stackView.addArrangedSubview(customizableButton)
  }
}

// MARK: - Layout

extension ViewController {
  private func layoutView() {
    layoutStackView()
    layoutButtons()
  }

  private func layoutStackView() {
    stackView.snp.makeConstraints {
      $0.centerY.leading.trailing.equalToSuperview()
    }
  }

  private func layoutButtons() {
    [ratioButton, customizableButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(48)
      }
    }
  }
}

// MARK: - Bind

extension ViewController {
  private func bindRx() {
    bindInput()
  }
}

// MARK: - Input

extension ViewController {
  private func bindInput() {
    bindRatioButton()
    bindCustomizableButton()
  }

  private func bindRatioButton() {
    ratioButton
      .rx
      .tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        PhotoCropper.shared.isCustomizedSizeEnabled = false

        let vc = RatioViewController()
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: bag)
  }

  private func bindCustomizableButton() {
    customizableButton
      .rx
      .tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        PhotoCropper.shared.isCustomizedSizeEnabled = true
        PhotoCropper.shared.hideFrameBorder = true
        PhotoCropper.shared.appearance.edgeButtonPathWidthMultiplier = 1.0

        let vc = CustomizableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: bag)
  }
}
