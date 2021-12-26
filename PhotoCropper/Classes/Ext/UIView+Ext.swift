//
//  UIView+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import UIKit

extension UIView {
  /// Layout with animation.
  func layoutIfNeeded(duration: CGFloat = PhotoCropper.shared.transitionDuration,
                      animated: Bool) {
    UIView.animate(withDuration: animated ? duration : .zero) {
      self.layoutIfNeeded()
    }
  }

  /// Show UIView
  func show(duration: CGFloat = PhotoCropper.shared.transitionDuration,
            animated: Bool = true,
            completion: ((Bool) -> Void)? = nil) {
    let duration: CGFloat = animated
      ? duration
      : .zero

    UIView.animate(withDuration: duration, animations: {
      self.alpha = 1
    }, completion: completion)
  }

  /// Hide UIView
  func hide(duration: CGFloat = PhotoCropper.shared.animationDuration,
            animated: Bool = true,
            completion: ((Bool) -> Void)? = nil) {
    let duration: CGFloat = animated
      ? duration
      : .zero

    UIView.animate(withDuration: duration, animations: {
      self.alpha = 0
    }, completion: completion)
  }
}
