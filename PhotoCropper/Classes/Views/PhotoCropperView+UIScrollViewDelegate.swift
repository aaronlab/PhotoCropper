//
//  PhotoCropperView+UIScrollViewDelegate.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/25.
//

import UIKit

// MARK: - UIScrollViewDelegate

extension PhotoCropperView: UIScrollViewDelegate {
  open func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
    return false
  }

  open func viewForZooming(in _: UIScrollView) -> UIView? {
    return imageView
  }

  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    if !scrollView.isZoomBouncing,
       scrollView.zoomScale < PhotoCropper.shared.maxZoomScale,
       scrollView.zoomScale > PhotoCropper.shared.minZoomScale {
      updateScroll(scrollView)
    }
  }

  public func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                      with _: UIView?,
                                      atScale _: CGFloat) {
    updateScroll(scrollView)
  }

  /// Update scroll
  open func updateScroll(_ scrollView: UIScrollView) {
    if scrollView.zoomScale > 1 {
      if let image = imageView.image {
        let verticalRatio = imageView.frame.width / image.size.width
        let horizontalRatio = imageView.frame.height / image.size.height
        let ratio = min(verticalRatio, horizontalRatio)

        let newWidth = image.size.width * ratio
        let scaledWidth = newWidth * scrollView.zoomScale
        let horizontalInset = scaledWidth > imageView.frame.width
          ? newWidth - imageView.frame.width
          : scrollView.frame.width - scrollView.contentSize.width

        let newHeight = image.size.height * ratio
        let scaledHeight = newHeight * scrollView.zoomScale
        let verticalInset = scaledHeight > imageView.frame.height
          ? newHeight - imageView.frame.height
          : scrollView.frame.height - scrollView.contentSize.height

        var left = (horizontalInset / 2)
        var top = (verticalInset / 2)

        // Insets for Grid

        let originHeight = imageView.frame.height / scrollView.zoomScale
        let gridTopThreshold = originHeight - gridView.frame.height
        let gridHeightDistance = newHeight - gridView.frame.height
        let extraTopForGrid = min(gridTopThreshold, gridHeightDistance) / 2
        top += extraTopForGrid

        let originWidth = imageView.frame.width / scrollView.zoomScale
        let gridLeftThreshold = originWidth - gridView.frame.width
        let gridWidthDistance = newWidth - gridView.frame.width
        let extraLeftForGrid = min(gridLeftThreshold, gridWidthDistance) / 2
        left += extraLeftForGrid

        scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
      }
    } else {
      scrollView.contentInset = .zero
    }

    lastScale = scrollView.zoomScale
  }
}
