# PhotoCropper

[![Platform](https://img.shields.io/cocoapods/p/PhotoCropper.svg?style=flat)](https://cocoapods.org/pods/PhotoCropper)
[![Language: Swift 5](https://img.shields.io/badge/language-Swift5-orange?style=flat&logo=swift)](https://developer.apple.com/swift)
![SwiftPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen?style=flat&logo=swift)
![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen?style=flat&logo=cocoapods)
[![Version](https://img.shields.io/cocoapods/v/PhotoCropper.svg?style=flat)](https://cocoapods.org/pods/PhotoCropper)
[![License](https://img.shields.io/cocoapods/l/PhotoCropper.svg?style=flat)](https://cocoapods.org/pods/PhotoCropper)

This is a simple image crop library for iOS on Christmas🎅 🎄for fun based on RxSwift,

which doesn't support customized resizing by users.

This would be appropriate when limiting crop rate control to users.

## Preview

[![Preview](./res/preview.gif)](./res/preview.gif)

## Requirements

- Swift 5

- iOS 10.0 +

- RxSwift 6.0

- RxCocoa 6.0

- RxGesture 4.0

- SnapKit 5.0

- Then 2.0

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

PhotoCropper is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PhotoCropper'
```

```commandline
$ pod install
```

### [Swift Package Manager(SPM)](https://www.swift.org/package-manager/)

In Xcode, add as Swift package with this URL: `https://github.com/aaronLab/PhotoCropper`

## Usage

1. Import `PhotoCropper` on top of your view controller file.

2. ⚠️ If you want to change the ratio or some configurations, you can change the values in `viewDidLoad` by the singleton instance called `PhotoCropper` "**_before you initialize the `PhotoCropperView`_**." For more information, please check the example files.

3. Create a view using `PhotoCropperView(with:)` in a `view controller`.

4. Make constraints of the `PhotoCropperView` you made in the `view controller`.

5. Subscribe the `resultImage: PublishSubject<UIImage?>` in the `PhotoCropperView` you declared and when the subjec emits the result image, you can go with that.

6. To change the ratio, use `PhotoCropper.shared.ratio: BehaviorRelay<CGFloat>` like below.
   - e.g. `PhotoCropper.shared.ratio.accept(2 / 3)`
   - **_2 / 3 means 2:3 ratio of the size._**

## Customization

### PhotoCropper

A singleton configuration instance.

> ⚠️ You should change the values before you initialize the view except the ratio and cornerRadius whose type is `BehaviorRelay<CGFloat>`.

`PhotoCropper.shared...`

```swift
/// The crop ratio
public var ratio: BehaviorRelay<CGFloat> { get }

/// Defines the `max zoom scale multiplier` by the `minZoomScale`
///
/// Default value is `5.0`
public var maxZoomScaleMultiplier: CGFloat

/// Hide grid
///
/// Default value is `false`
public var hideGrid: Boo

/// Hide frame border
///
/// Default value is `false`
public var hideFrameBorder: Bool

/// Hide the overlay views on the image
///
/// Default value is `false`
public var hideOverlay: Bool

/// Appearance
public var appearance: PhotoCropperAppearance

/// Defines the transition duration.
///
/// The default value is `0.25`
public var transitionDuration: CGFloat

/// Defines the animation duration.
///
/// The default value is `0.3`
public var animationDuration: CGFloat

/// Grid hide delay duration
///
/// - This defines the duration of when the grid will be hidden after user interaction done.
///
/// Default duration is `0.3`
public var gridHideDelayDuration: TimeInterval

/// Number of the grid lines
///
/// The number of the grid lines in the frame by each orientation.
///
/// Default duration is `3`
public var numberOfGridLines
```

### PhotoCropperAppearance

Appearance configurations.

> You can change the values from `PhotoCropper` singleton instance.

`PhotoCropper.shared.appearance...`

```swift
/// Corner radius of the frame.
///
/// Default value is `0`
public var cornerRadius: BehaviorRelay<CGFloat>

/// The color of `frame`.
///
/// Default value is `.white`
public var frameColor: UIColor

/// The color of `grid`.
///
/// Default value is `.white`
public var gridColor: UIColor

/// The color of the overlay for the image out of the frame.
///
/// Default value is `.black.withAlphaComponent(0.6)`
public var overlayColor: UIColor

/// The frame border width
///
/// Default value is `2.0`
public var frameBorderWidth: CGFloat

/// The grid width
///
/// Default value is `1.0`
public var gridWidth: CGFloat
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
//
//  ViewController.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 12/26/2021.
//  Copyright (c) 2021 Aaron Lee. All rights reserved.
//

import UIKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import PhotoCropper

class ViewController: UIViewController {

  private var bag = DisposeBag()

  private var doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                           target: nil,
                                           action: nil)

  private var photoCropperView = PhotoCropperView(with: UIImage(named: "image"))

  private var stackView = UIStackView()
    .then {
      $0.axis = .vertical
      $0.spacing = 8
      $0.distribution = .fill
      $0.alignment = .fill
    }

  private var orientationSegmentedControl = UISegmentedControl(
    items: Orientation.allCases.map { $0.rawValue }
  )

  private var ratioSegmentedControl = UISegmentedControl(
    items: Ratio.allCases.map { $0.description(by: .landscape) }
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
    layoutView()
    bindRx()
  }

}

// MARK: - Configure

extension ViewController {

  private func configureView() {
    title = "PhotoCropper Example"
    navigationItem.rightBarButtonItem = doneButton

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
  }

}

// MARK: - Layout

extension ViewController {

  private func layoutView() {
    view.addSubview(photoCropperView)
    view.addSubview(stackView)

    layoutPhotoCropperView()
    layoutStackView()
    layoutSegmentedControls()
  }

  private func layoutPhotoCropperView() {
    photoCropperView.snp.makeConstraints {
      $0.top.leading.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(stackView.snp.top)
    }
  }

  private func layoutStackView() {

    stackView.snp.makeConstraints {
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
      $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
    }
  }

  private func layoutSegmentedControls() {
    [orientationSegmentedControl, ratioSegmentedControl].forEach {
      $0.selectedSegmentIndex = 0
      stackView.addArrangedSubview($0)
      $0.snp.makeConstraints {
        $0.height.equalTo(30)
      }
    }
  }

}

// MARK: - Bind

extension ViewController {

  private func bindRx() {
    bindInput()
    bindOutput()
  }

}

// MARK: - Input

extension ViewController {

  private func bindInput() {
    bindDoneButton()
    bindOrientationSegmentedControlSelectedIndex()
    bindRatioSegmentedControlSelectedIndex()
  }

  private func bindDoneButton() {
    doneButton.rx.tap
      .bind(to: photoCropperView.crop)
      .disposed(by: bag)
  }

  private func bindOrientationSegmentedControlSelectedIndex(){
    orientationSegmentedControl
      .rx
      .selectedSegmentIndex
      .skip(1)
      .map { [weak self] index -> CGFloat in
        guard let self = self else { return 1 }
        let orientation = Orientation.allCases[index]
        let ratio = Ratio.allCases[self.ratioSegmentedControl.selectedSegmentIndex]
        let ratioValue = ratio.ratio(by: orientation)
        return ratioValue
      }
      .bind(to: PhotoCropper.shared.ratio)
      .disposed(by: bag)
  }

  private func bindRatioSegmentedControlSelectedIndex() {
    ratioSegmentedControl
      .rx
      .selectedSegmentIndex
      .skip(1)
      .map { [weak self] index -> CGFloat in
        guard let self = self else { return 1 }
        let orientation = Orientation.allCases[self.orientationSegmentedControl.selectedSegmentIndex]
        let ratio = Ratio.allCases[index]
        let ratioValue = ratio.ratio(by: orientation)
        return ratioValue
      }
      .bind(to: PhotoCropper.shared.ratio)
      .disposed(by: bag)
  }

}

// MARK: - Output

extension ViewController {

  private func bindOutput() {
    photoCropperView.resultImage
      .subscribe(onNext: { [weak self] image in
        guard let self = self else { return }

        let vc = ResultImageViewController()
        vc.imageView.image = image
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: bag)
  }

}

```

## Author

Aaron Lee, aaronlab.net@gmail.com

## License

PhotoCropper is available under the MIT license. See the [LICENSE](https://github.com/aaronLab/PhotoCropper/blob/master/LICENSE) file for more info.
