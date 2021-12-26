//
//  Ratio.swift
//  PhotoCropper_Example
//
//  Created by Aaron Lee on 2021/12/26.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

enum Ratio: String, CaseIterable {
  case square = "1:1"
  case sixteenToNine = "16:9"
  case fiveToFour = "5:4"
  case sevenToFive = "7:5"
  case fourToThree = "4:3"
  case fiveToThree = "5:3"
  case threeToTwo = "3:2"
}

extension Ratio {
  func description(by orientation: Orientation) -> String {
    switch orientation {
    case .landscape:
      return rawValue
    case .portrait:
      var split = rawValue.split(separator: ":")

      split.swapAt(0, split.count - 1)

      let newRawValue = split.joined(separator: ":")

      return newRawValue
    }
  }

  func ratio(by orientation: Orientation) -> CGFloat {
    let description = description(by: orientation).split(separator: ":")

    guard let left = description.first,
          let leftDouble = Double(String(left)),
          let right = description.last,
          let rightDouble = Double(String(right)) else {
      return 1
    }

    let leftCGFloat = CGFloat(leftDouble)
    let rightCGFloat = CGFloat(rightDouble)

    return leftCGFloat / rightCGFloat
  }
}
