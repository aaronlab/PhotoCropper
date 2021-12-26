//
//  PhotoCropperOverlayView.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/25.
//

import UIKit

/// PhotoCropperOverlayView
open class PhotoCropperOverlayView: UIView {
  // MARK: - Private Properties

  /// Overlay mask layer
  private var overlayMaskLayer = CAShapeLayer()

  // MARK: - Init

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }

  // MARK: - Configure

  open func configureView() {
    isUserInteractionEnabled = false
    backgroundColor = PhotoCropper.shared.appearance.overlayColor
    isHidden = PhotoCropper.shared.hideOverlay
    layer.mask = overlayMaskLayer
  }

  // MARK: - Helpers

  open func updateOverlayMaskLayer(in visibleRect: CGRect) {
    let radius: CGFloat = PhotoCropper.shared.appearance.cornerRadius.value

    let path = UIBezierPath(rect: bounds)
    let visiblePath = UIBezierPath(roundedRect: visibleRect, cornerRadius: radius)
    path.append(visiblePath)

    overlayMaskLayer.fillRule = .evenOdd

    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = overlayMaskLayer.path
    animation.toValue = path.cgPath
    animation.duration = PhotoCropper.shared.transitionDuration
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    overlayMaskLayer.add(animation, forKey: nil)

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    overlayMaskLayer.path = path.cgPath
    CATransaction.commit()
  }
}
