//
//  PhotoCropperScrollView.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import SnapKit
import Then
import UIKit

/// PhotoCropperScrollView
open class PhotoCropperScrollView: UIScrollView {
  // MARK: - Init

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }

  open func configureView() {
    alwaysBounceVertical = false
    alwaysBounceHorizontal = false
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    contentMode = .topRight
  }
}
