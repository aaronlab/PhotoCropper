//
//  Observable+Ext.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/31.
//

import Foundation
import RxSwift

// MARK: - Observable

extension Observable {
  func toVoid() -> Observable<Void> {
    return map { _ in () }
  }
}
