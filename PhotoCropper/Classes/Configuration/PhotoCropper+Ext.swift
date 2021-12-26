//
//  PhotoCropper+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import UIKit

public extension PhotoCropper {
  /// Returns the zoom scales based on the min/max scale.
  @discardableResult
  func zoomScales(by _: CGSize,
                  in cropper: PhotoCropperView)
    -> PhotoCropperMinMax {
    let scrollView = cropper.scrollView
    let imageView = cropper.imageView
    let image = imageView.image!

    let verticalRatio = imageView.frame.width / image.size.width
    let horizontalRatio = imageView.frame.height / image.size.height
    let imageRatio = verticalRatio < horizontalRatio ? verticalRatio : horizontalRatio

    let imageWidth = image.size.width / scrollView.zoomScale * imageRatio
    let imageHeight = image.size.height / scrollView.zoomScale * imageRatio

    let gridWidth = cropper.gridView.frame.width
    let gridHeight = cropper.gridView.frame.height

    let min = max(max(gridWidth / imageWidth, gridHeight / imageHeight), 1.001)
    let max = min * maxZoomScaleMultiplier

    return (min: min, max: max)
  }

  /// Crop image
  func cropImage(to rect: CGRect,
                 imageView: UIImageView)
    -> UIImage? {
    guard let image = imageView.image else { return nil }

    let imageViewWidth = imageView.frame.width
    let imageViewHeight = imageView.frame.height
    let imageHoriziontalScale = image.size.width / imageViewWidth
    let imageVerticalScale = image.size.height / imageViewHeight
    let scale = max(imageHoriziontalScale, imageVerticalScale)

    let cropRect = CGRect(x: rect.origin.x * scale,
                          y: rect.origin.y * scale,
                          width: rect.size.width * scale,
                          height: rect.size.height * scale)

    guard let cropRef = image.cgImage?.cropping(to: cropRect) else { return nil }

    let result = UIImage(cgImage: cropRef)

    return result
  }
}
