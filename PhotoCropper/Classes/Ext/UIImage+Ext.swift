//
//  UIImage+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import UIKit

extension UIImageView {
  // MARK: - Methods

  func imageRect() -> CGRect {
    guard let imageSize = image?.size else { return CGRect.zero }

    let size = frame.size
    let horizontalAspect = size.width / imageSize.width
    let verticalAspect = size.height / imageSize.height
    let aspect = min(horizontalAspect, verticalAspect)

    let scaledWidth = imageSize.width * aspect
    let scaledHeight = imageSize.height * aspect
    let x = (size.width - scaledWidth) / 2
    let y = (size.height - scaledHeight) / 2

    let imageRect = CGRect(x: x + frame.origin.x,
                           y: y + frame.origin.y,
                           width: scaledWidth,
                           height: scaledHeight)

    return imageRect
  }
}
