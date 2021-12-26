//
//  AppDelegate.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 12/26/2021.
//  Copyright (c) 2021 Aaron Lee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let vc = ViewController()
    let navC = UINavigationController(rootViewController: vc)

    window = UIWindow()
    window?.rootViewController = navC
    window?.makeKeyAndVisible()

    return true
  }
}
