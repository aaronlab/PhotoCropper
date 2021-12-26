//
//  PhotoCropper.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import RxCocoa
import UIKit

/// Min / Max
public typealias PhotoCropperMinMax = (min: CGFloat, max: CGFloat)

/// PhotoCropper configurations.
public final class PhotoCropper {
  private init() {}

  public private(set) static var shared = PhotoCropper()

  /// The crop ratio
  public private(set) var ratio: BehaviorRelay<CGFloat> = BehaviorRelay(value: 1 / 1)

  // MARK: - Scales

  /// Defines the `max zoom scale multiplier` by the `minZoomScale`
  ///
  /// Default value is `5.0`
  public var maxZoomScaleMultiplier: CGFloat = 5.0

  /// Min zoom scale
  internal var minZoomScale: CGFloat = 1.0

  /// Max zoom scale
  internal var maxZoomScale: CGFloat = 5.0

  // MARK: - Grid

  /// Hide grid
  ///
  /// Default value is `false`
  public var hideGrid: Bool = false

  /// Hide frame border
  ///
  /// Default value is `false`
  public var hideFrameBorder: Bool = false

  /// Hide the overlay views on the image
  ///
  /// Default value is `false`
  public var hideOverlay: Bool = false

  // MARK: - Appearance

  /// Appearance
  public var appearance = PhotoCropperAppearance()

  // MARK: - Durations

  /// Defines the transition duration.
  ///
  /// The default value is `0.25`
  public var transitionDuration: CGFloat = 0.25

  /// Defines the animation duration.
  ///
  /// The default value is `0.3`
  public var animationDuration: CGFloat = 0.3

  /// Grid hide delay duration
  ///
  /// - This defines the duration of when the grid will be hidden after user interaction done.
  ///
  /// Default duration is `0.3`
  public var gridHideDelayDuration: TimeInterval = 0.3

  /// Number of the grid lines
  ///
  /// The number of the grid lines in the frame by each orientation.
  ///
  /// Default duration is `3`
  public var numberOfGridLines: Int = 3
}
