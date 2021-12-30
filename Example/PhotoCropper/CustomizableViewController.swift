//
//  CustomizableViewController.swift
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

class CustomizableViewController: UIViewController {
  private var bag = DisposeBag()

  private var doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                           target: nil,
                                           action: nil)

  private var photoCropperView = PhotoCropperView()
    .then {
      let names = ["image1", "image2", "image3", "image4"]
      guard let imageName = names.randomElement() else { return }
      $0.imageView.image = UIImage(named: imageName)
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    layoutView()
    bindRx()
  }
}

// MARK: - Configure

extension CustomizableViewController {
  private func configureView() {
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    title = "Customizable Size"

    navigationItem.rightBarButtonItem = doneButton

    view.addSubview(photoCropperView)
  }
}

// MARK: - Layout

extension CustomizableViewController {
  private func layoutView() {
    layoutPhotoCropperView()
  }

  private func layoutPhotoCropperView() {
    photoCropperView.snp.makeConstraints {
      $0.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

// MARK: - Bind

extension CustomizableViewController {
  private func bindRx() {
    bindInput()
    bindOutput()
  }
}

// MARK: - Input

extension CustomizableViewController {
  private func bindInput() {
    bindDoneButton()
  }

  private func bindDoneButton() {
    doneButton
      .rx
      .tap
      .bind(to: photoCropperView.crop)
      .disposed(by: bag)
  }
}

// MARK: - Output

extension CustomizableViewController {
  private func bindOutput() {
    bindResultImage()
  }

  private func bindResultImage() {
    photoCropperView
      .resultImage
      .subscribe(onNext: { [weak self] image in
        guard let self = self else { return }

        let vc = ResultImageViewController()
        vc.imageView.image = image
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: bag)
  }
}
