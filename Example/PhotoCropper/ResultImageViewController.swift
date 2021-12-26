//
//  ResultImageViewController.swift
//  PhotoCropper_Example
//
//  Created by Aaron Lee on 2021/12/26.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import Then
import UIKit

class ResultImageViewController: UIViewController {
  private(set) var imageView = UIImageView()
    .then {
      $0.contentMode = .scaleAspectFit
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    layoutView()
  }
}

// MARK: - Configure

extension ResultImageViewController {
  private func configureView() {
    title = "Cropped"

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
  }
}

// MARK: - Layout

extension ResultImageViewController {
  private func layoutView() {
    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}
