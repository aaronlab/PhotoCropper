//
//  UIView+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import RxGesture
import RxSwift
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

  /// Draw line
  func drawLine(from start: CGPoint,
                to end: CGPoint,
                color: UIColor = PhotoCropper.shared.appearance.edgeButtonColor,
                lineWidth: CGFloat = PhotoCropper.shared.appearance.edgeButtonBorderWidth) {
    let line = CAShapeLayer()
    let linePath = UIBezierPath()
    linePath.move(to: start)
    linePath.addLine(to: end)
    line.path = linePath.cgPath
    line.fillColor = nil
    line.opacity = 1.0
    line.strokeColor = color.cgColor
    line.lineWidth = lineWidth
    layer.addSublayer(line)
  }

  /// Pan Gesture Observable
  func panGesture(state: UIPanGestureRecognizer.State)
    -> Observable<UIPanGestureRecognizer> {
    return rx
      .panGesture(configuration: nil)
      .when(state)
  }
}
