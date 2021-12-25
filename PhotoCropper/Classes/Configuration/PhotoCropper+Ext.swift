//
//  PhotoCropper+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import UIKit

extension PhotoCropper {
  
  /// Returns the zoom scales based on the min/max scale.
  @discardableResult
  public func zoomScales(by imageSize: CGSize) -> PhotoCropperMinMax {
    let imageSizeRatio = imageSize.width / imageSize.height
    let imageHeightRatio = 1 / imageSizeRatio
    
    let ratio = ratio.value
    let heightRatio = ratio == 1 ? ratio : 1 / ratio
    
    var minScale: CGFloat = .zero
    
    if heightRatio > imageHeightRatio {
      // Image height is smaller than the scroll view
      let scale = heightRatio / imageHeightRatio
      minScale = scale
      
    } else {
      // Image width is smaller than the scroll view
      let scale = imageHeightRatio / heightRatio
      minScale = scale
    }
    
    let maxScale: CGFloat = minScale * maxZoomScaleMultiplier
    
    minZoomScale = minScale
    maxZoomScale = maxScale
    
    return (min: minScale, max: maxScale)
  }
  
  /// Crop image
  public func cropImage(to rect: CGRect,
                        imageView: UIImageView) -> UIImage? {
    guard let image = imageView.image else { return nil }
    
    let imageViewWidth  = imageView.frame.width
    let imageViewHeight = imageView.frame.height
    let imageHoriziontalScale = image.size.width / imageViewWidth
    let imageVerticalScale = image.size.height / imageViewHeight
    let scale = max(imageHoriziontalScale, imageVerticalScale)
    
    let cropRect = CGRect(x: rect.origin.x * scale,
                          y: rect.origin.y * scale,
                          width: rect.size.width * scale,
                          height: rect.size.height * scale)
    
    guard let cropRef = image.cgImage?.cropping(to: cropRect) else { return nil }
    
    let result: UIImage = UIImage(cgImage: cropRef)
    
    return result
  }
  
}
