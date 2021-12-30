//
//  PhotoCropperEdgeButton.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/30.
//

import SnapKit
import Then
import UIKit

/// PhotoCropperEdgeButton
open class PhotoCropperEdgeButton: UIButton {
  // MARK: - Public Properties

  public var position: PhotoCropperEdgeButtonPosition!

  // MARK: - Init

  public convenience init(with position: PhotoCropperEdgeButtonPosition,
                          frame: CGRect = .zero) {
    self.init(frame: frame)
    self.position = position
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)

    let horizontalFrom = CGPoint(x: horizontalXFrom(),
                                 y: horizontalY())
    let horizontalTo = CGPoint(x: horizontalXTo(),
                               y: horizontalY())
    drawLine(from: horizontalFrom,
             to: horizontalTo)

    let verticalFrom = CGPoint(x: verticalX(),
                               y: verticalYFrom())
    let verticalTo = CGPoint(x: verticalX(),
                             y: verticalYTo())
    drawLine(from: verticalFrom,
             to: verticalTo)
  }

  private func horizontalXFrom() -> CGFloat {
    if position.left {
      return .zero
    }

    let leftSpace = frame.width * PhotoCropper.shared.appearance.edgeButtonPathWidthMultiplier
    return frame.width - leftSpace
  }

  private func horizontalXTo() -> CGFloat {
    if position.left {
      return frame.width * PhotoCropper.shared.appearance.edgeButtonPathWidthMultiplier
    }

    return frame.width
  }

  private func horizontalY() -> CGFloat {
    if position.top {
      return PhotoCropper.shared.appearance.edgeButtonBorderWidth / 2
    }

    return frame.height - PhotoCropper.shared.appearance.edgeButtonBorderWidth / 2
  }

  private func verticalX() -> CGFloat {
    if position.left {
      return PhotoCropper.shared.appearance.edgeButtonBorderWidth / 2
    }

    return frame.width - (PhotoCropper.shared.appearance.edgeButtonBorderWidth / 2)
  }

  private func verticalYFrom() -> CGFloat {
    if position.top {
      return .zero
    }

    let topSpace = frame.height * PhotoCropper.shared.appearance.edgeButtonPathWidthMultiplier
    return frame.height - topSpace
  }

  private func verticalYTo() -> CGFloat {
    if position.top {
      return frame.height * PhotoCropper.shared.appearance.edgeButtonPathWidthMultiplier
    }

    return frame.height
  }
}
