//
//  PhotoCropperEdgeButtonPosition.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/30.
//

import UIKit

/// PhotoCropperEdgeButtonPosition
public enum PhotoCropperEdgeButtonPosition {
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
}

extension PhotoCropperEdgeButtonPosition {
  var top: Bool {
    return self == .topLeft || self == .topRight
  }

  var left: Bool {
    return self == .topLeft || self == .bottomLeft
  }
}
