//
//  Constraint+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/30.
//

import Foundation
import SnapKit

extension SnapKit.Constraint {
  var constant: CGFloat {
    guard let constant = layoutConstraints.first.map(\.constant) else {
      return .zero
    }
    return constant
  }
}
