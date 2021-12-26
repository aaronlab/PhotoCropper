//
//  ViewController.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 12/26/2021.
//  Copyright (c) 2021 Aaron Lee. All rights reserved.
//

import UIKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import PhotoCropper

class ViewController: UIViewController {

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
  
  private var stackView = UIStackView()
    .then {
      $0.axis = .vertical
      $0.spacing = 8
      $0.distribution = .fill
      $0.alignment = .fill
    }
  
  private var orientationSegmentedControl = UISegmentedControl(
    items: Orientation.allCases.map { $0.rawValue }
  )
  
  private var ratioSegmentedControl = UISegmentedControl(
    items: Ratio.allCases.map { $0.description(by: .landscape) }
  )
  
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
    title = "PhotoCropper Example"
    navigationItem.rightBarButtonItem = doneButton
    
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
  }
  
}

// MARK: - Layout

extension ViewController {
  
  private func layoutView() {
    view.addSubview(photoCropperView)
    view.addSubview(stackView)
    
    layoutPhotoCropperView()
    layoutStackView()
    layoutSegmentedControls()
  }
  
  private func layoutPhotoCropperView() {
    photoCropperView.snp.makeConstraints {
      $0.top.leading.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(stackView.snp.top)
    }
  }
  
  private func layoutStackView() {
    
    stackView.snp.makeConstraints {
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
      $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
    }
  }
  
  private func layoutSegmentedControls() {
    [orientationSegmentedControl, ratioSegmentedControl].forEach {
      $0.selectedSegmentIndex = 0
      stackView.addArrangedSubview($0)
      $0.snp.makeConstraints {
        $0.height.equalTo(30)
      }
    }
  }
  
}

// MARK: - Bind

extension ViewController {
  
  private func bindRx() {
    bindInput()
    bindOutput()
  }
  
}

// MARK: - Input

extension ViewController {
  
  private func bindInput() {
    bindDoneButton()
    bindOrientationSegmentedControlSelectedIndex()
    bindRatioSegmentedControlSelectedIndex()
  }
  
  private func bindDoneButton() {
    doneButton.rx.tap
      .bind(to: photoCropperView.crop)
      .disposed(by: bag)
  }
  
  private func bindOrientationSegmentedControlSelectedIndex(){
    orientationSegmentedControl
      .rx
      .selectedSegmentIndex
      .skip(1)
      .map { [weak self] index -> CGFloat in
        guard let self = self else { return 1 }
        let orientation = Orientation.allCases[index]
        let ratio = Ratio.allCases[self.ratioSegmentedControl.selectedSegmentIndex]
        let ratioValue = ratio.ratio(by: orientation)
        return ratioValue
      }
      .bind(to: PhotoCropper.shared.ratio)
      .disposed(by: bag)
  }
  
  private func bindRatioSegmentedControlSelectedIndex() {
    ratioSegmentedControl
      .rx
      .selectedSegmentIndex
      .skip(1)
      .map { [weak self] index -> CGFloat in
        guard let self = self else { return 1 }
        let orientation = Orientation.allCases[self.orientationSegmentedControl.selectedSegmentIndex]
        let ratio = Ratio.allCases[index]
        let ratioValue = ratio.ratio(by: orientation)
        return ratioValue
      }
      .bind(to: PhotoCropper.shared.ratio)
      .disposed(by: bag)
  }
  
}

// MARK: - Output

extension ViewController {
  
  private func bindOutput() {
    photoCropperView.resultImage
      .subscribe(onNext: { [weak self] image in
        guard let self = self else { return }
        
        let vc = ResultImageViewController()
        vc.imageView.image = image
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: bag)
  }
  
}
