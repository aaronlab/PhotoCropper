//
//  PhotoCropperView.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

/// PhotoCropperView
open class PhotoCropperView: UIView {
  // MARK: - Public Properties

  /// Scroll view
  public var scrollView = PhotoCropperScrollView()

  /// Crop image trigger
  public private(set) var crop = PublishSubject<Void>()

  /// Result image subject
  public private(set) var resultImage = PublishSubject<UIImage?>()

  /// Image view
  ///
  /// The default contentMode is `.scaleAspectFit`
  public var imageView: UIImageView = .init()
    .then {
      $0.contentMode = .scaleAspectFit
    }

  /// Grid view
  public var gridView = PhotoCropperFrameGridView()
    .then {
      $0.isUserInteractionEnabled = false
    }

  /// Overlay
  public var overlayView = PhotoCropperOverlayView()

  /// Top left edge button
  public var topLeftEdgeButton = PhotoCropperEdgeButton(with: .topLeft)
    .then {
      $0.isHidden = !PhotoCropper.shared.isCustomizedSizeEnabled
    }

  /// Top right edge button
  public var topRightEdgeButton = PhotoCropperEdgeButton(with: .topRight)
    .then {
      $0.isHidden = !PhotoCropper.shared.isCustomizedSizeEnabled
    }

  /// Bottom left edge button
  public var bottomLeftEdgeButton = PhotoCropperEdgeButton(with: .bottomLeft)
    .then {
      $0.isHidden = !PhotoCropper.shared.isCustomizedSizeEnabled
    }

  /// Bottom right edge button
  public var bottomRightEdgeButton = PhotoCropperEdgeButton(with: .bottomRight)
    .then {
      $0.isHidden = !PhotoCropper.shared.isCustomizedSizeEnabled
    }

  // MARK: - Internal Properties

  internal var bag = DisposeBag()

  internal var lastScale: CGFloat = .zero

  internal var topLeftEdgeButtonTop: Constraint!
  internal var topLeftEdgeButtonTopConstant: CGFloat {
    return topLeftEdgeButtonTop?.constant ?? .zero
  }

  internal var topLeftEdgeButtonLeading: Constraint!
  internal var topLeftEdgeButtonLeadingConstant: CGFloat {
    return topLeftEdgeButtonLeading?.constant ?? .zero
  }

  internal var topRightEdgeButtonTop: Constraint!
  internal var topRightEdgeButtonTopConstant: CGFloat {
    return topRightEdgeButtonTop?.constant ?? .zero
  }

  internal var topRightEdgeButtonTrailing: Constraint!
  internal var topRightEdgeButtonTrailingConstant: CGFloat {
    return topRightEdgeButtonTrailing?.constant ?? .zero
  }

  internal var bottomLeftEdgeButtonBottom: Constraint!
  internal var bottomLeftEdgeButtonBottomConstant: CGFloat {
    return bottomLeftEdgeButtonBottom?.constant ?? .zero
  }

  internal var bottomLeftEdgeButtonLeading: Constraint!
  internal var bottomLeftEdgeButtonLeadingConstant: CGFloat {
    return bottomLeftEdgeButtonLeading?.constant ?? .zero
  }

  internal var bottomRightEdgeButtonBottom: Constraint!
  internal var bottomRightEdgeButtonBottomConstant: CGFloat {
    bottomRightEdgeButtonBottom?.constant ?? .zero
  }

  internal var bottomRightEdgeButtonTrailing: Constraint!
  internal var bottomRightEdgeButtonTrailingConstant: CGFloat {
    return bottomRightEdgeButtonTrailing?.constant ?? .zero
  }

  // MARK: - Private Properties

  private var ratioChanged: Bool = false

  private var lastOrientation: UIDeviceOrientation?

  private let edgeButtonWidth = PhotoCropper.shared.appearance.edgeButtonWidth

  // MARK: - Init

  public convenience init(with image: UIImage?) {
    self.init(frame: .zero)
    imageView.image = image
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
    layoutView()
    bindRx()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
    layoutView()
    bindRx()
  }

  deinit { bag = DisposeBag() }

  override open func layoutSubviews() {
    super.layoutSubviews()

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      self.updateZoomScale()
      self.overlayView.updateOverlayMaskLayer(in: self.gridView.frame)
    }
  }

  // MARK: - Helpers

  /// Update zoom scale
  open func updateZoomScale() {
    guard let imageSize = imageView.image?.size else { return }

    let scale = PhotoCropper.shared.zoomScales(by: imageSize, in: self)

    scrollView.minimumZoomScale = scale.min
    scrollView.maximumZoomScale = scale.max

    let currentOrientation = UIDevice.current.orientation

    if lastScale != .zero,
       scrollView.zoomScale >= scale.min,
       scrollView.zoomScale <= scale.max,
       currentOrientation == lastOrientation {
      updateScroll(scrollView)

    } else {
      let duration = ratioChanged ? PhotoCropper.shared.transitionDuration : .zero
      ratioChanged.toggle()
      lastScale = scale.min
      UIView.animate(withDuration: duration) {
        self.scrollView.setZoomScale(scale.min, animated: false)
      } completion: { _ in
        self.updateScroll(self.scrollView)
      }
    }

    lastOrientation = UIDevice.current.orientation
  }

  // MARK: - Configure

  open func configureView() {
    // Scroll
    scrollView.delegate = self
    addSubview(scrollView)
    scrollView.addSubview(imageView)

    // Grid
    addSubview(gridView)

    // Overlay
    addSubview(overlayView)

    // Edges
    addSubview(topLeftEdgeButton)
    addSubview(topRightEdgeButton)
    addSubview(bottomLeftEdgeButton)
    addSubview(bottomRightEdgeButton)
  }

  // MARK: - Layout

  open func layoutView() {
    layoutScrollView()
    layoutImageView()
    layoutGridView()
    layoutOverlayView()
    layoutEdgeButtons()
  }

  // MARK: - Bind

  open func bindRx() {
    bindRatio()
    bindCrop()
    bindScrollViewGestures()
    bindEdgeButtonGestures()
  }
}

// MARK: - Layout

extension PhotoCropperView {
  private func layoutScrollView() {
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  private func layoutImageView() {
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.center.equalToSuperview()
    }
  }

  private func layoutGridView() {
    let ratio = PhotoCropper.shared.ratio.value
    let heightRatio = ratio == 1 ? ratio : 1 / ratio

    gridView.snp.removeConstraints()
    gridView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().priority(.high)
      $0.top.leading.greaterThanOrEqualToSuperview()
      $0.bottom.trailing.lessThanOrEqualToSuperview()
      $0.center.equalToSuperview()
      $0.height.equalTo(gridView.snp.width).multipliedBy(heightRatio)
    }
  }

  private func layoutOverlayView() {
    overlayView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  /// Layout edge buttons
  private func layoutEdgeButtons() {
    layoutTopLeftEdgeButton()
    layoutTopRightEdgeButton()
    layoutBottomLeftEdgeButton()
    layoutBottomRightEdgeButton()
  }

  private func layoutTopLeftEdgeButton() {
    topLeftEdgeButton.snp.makeConstraints {
      topLeftEdgeButtonTop = $0.top.equalTo(gridView).constraint
      topLeftEdgeButtonLeading = $0.leading.equalTo(gridView).constraint
      $0.width.height.equalTo(edgeButtonWidth)
    }
  }

  private func layoutTopRightEdgeButton() {
    topRightEdgeButton.snp.makeConstraints {
      topRightEdgeButtonTop = $0.top.equalTo(gridView).constraint
      topRightEdgeButtonTrailing = $0.trailing.equalTo(gridView).constraint
      $0.width.height.equalTo(edgeButtonWidth)
    }
  }

  private func layoutBottomLeftEdgeButton() {
    bottomLeftEdgeButton.snp.makeConstraints {
      bottomLeftEdgeButtonBottom = $0.bottom.equalTo(gridView).constraint
      bottomLeftEdgeButtonLeading = $0.leading.equalTo(gridView).constraint
      $0.width.height.equalTo(edgeButtonWidth)
    }
  }

  private func layoutBottomRightEdgeButton() {
    bottomRightEdgeButton.snp.makeConstraints {
      bottomRightEdgeButtonBottom = $0.bottom.equalTo(gridView).constraint
      bottomRightEdgeButtonTrailing = $0.trailing.equalTo(gridView).constraint
      $0.width.height.equalTo(edgeButtonWidth)
    }
  }
}

// MARK: - Bind

extension PhotoCropperView {
  private func bindRatio() {
    PhotoCropper.shared.ratio
      .skip(1)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }

        self.ratioChanged = true
        self.layoutGridView()
        self.layoutIfNeeded(animated: true)
      })
      .disposed(by: bag)
  }

  private func bindCrop() {
    crop
      .subscribe(onNext: { [weak self] in
        guard let self = self,
              self.imageView.image != nil else {
          return
        }

        let convertedRect = self.gridView.convert(self.gridView.frame,
                                                  to: self.scrollView)
        let rect = self.gridView.frame
        let gridBorderWidth = self.gridView.layer.borderWidth

        let frameX = convertedRect.origin.x - rect.origin.x + gridBorderWidth
        let frameY = convertedRect.origin.y - rect.origin.y + gridBorderWidth

        let imageRect = self.imageView.imageRect()

        let cropRect = CGRect(x: frameX - imageRect.origin.x,
                              y: frameY - imageRect.origin.y,
                              width: rect.width - (gridBorderWidth * 2),
                              height: rect.height - (gridBorderWidth * 2))

        let croppedImage = PhotoCropper.shared.cropImage(to: cropRect,
                                                         imageView: self.imageView)

        DispatchQueue.main.async {
          self.resultImage.onNext(croppedImage)
        }

      })
      .disposed(by: bag)
  }

  private func bindScrollViewGestures() {
    scrollView.rx.didZoom
      .skip(1)
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    scrollView.rx.didScroll
      .filter { [weak self] in
        guard let self = self else { return false }
        return self.scrollView.isDragging
      }
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    scrollView.rx.didEndDragging
      .map { _ in () }
      .bind(to: gridView.gridLinesWillHide)
      .disposed(by: bag)

    scrollView.rx.didEndDecelerating
      .bind(to: gridView.gridLinesWillHide)
      .disposed(by: bag)

    scrollView.rx.didEndZooming
      .map { _ in () }
      .bind(to: gridView.gridLinesWillHide)
      .disposed(by: bag)
  }
}
