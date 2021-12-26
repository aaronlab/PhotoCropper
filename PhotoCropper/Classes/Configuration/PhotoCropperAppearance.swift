//
//  PhotoCropperAppearance.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/18.
//

import RxCocoa
import UIKit

/// The appearance of PhotoCropper
public struct PhotoCropperAppearance {
  // MARK: - Styles

  /// Corner radius of the frame.
  ///
  /// Default value is `0`
  public var cornerRadius: BehaviorRelay<CGFloat> = BehaviorRelay(value: 0)

  // MARK: - Colors

  /// The color of `frame`.
  ///
  /// Default value is `.white`
  public var frameColor: UIColor = .white

  /// The color of `grid`.
  ///
  /// Default value is `.white`
  public var gridColor: UIColor = .white

  /// The color of the overlay for the image out of the frame.
  ///
  /// Default value is `.black.withAlphaComponent(0.6)`
  public var overlayColor: UIColor = .black.withAlphaComponent(0.6)

  // MARK: - Size

  /// The frame border width
  ///
  /// Default value is `2.0`
  public var frameBorderWidth: CGFloat = 2.0

  /// The grid width
  ///
  /// Default value is `1.0`
  public var gridWidth: CGFloat = 1.0
}
