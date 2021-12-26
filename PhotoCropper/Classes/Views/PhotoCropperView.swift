//
//  PhotoCropperView.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/24.
//

import RxSwift
import SnapKit
import Then
import UIKit

/// PhotoCropperView
open class PhotoCropperView: UIView {
  // MARK: - Public Properties

  /// Scroll view
  public private(set) var scrollView = PhotoCropperScrollView()

  /// Crop image trigger
  public private(set) var crop = PublishSubject<Void>()

  /// Result image subject
  public private(set) var resultImage = PublishSubject<UIImage?>()

  /// Image view
  ///
  /// The default contentMode is `.scaleAspectFit`
  public private(set) var imageView: UIImageView = .init()
    .then {
      $0.contentMode = .scaleAspectFit
    }

  /// Grid view
  public private(set) var gridView = PhotoCropperFrameGridView()
    .then {
      $0.isUserInteractionEnabled = false
    }

  /// Overlay
  public private(set) var overlayView = PhotoCropperOverlayView()

  // MARK: - Internal Properties

  internal var lastScale: CGFloat = .zero

  // MARK: - Private Properties

  private var bag = DisposeBag()

  private var ratioChanged: Bool = false

  private var lastOrientation: UIDeviceOrientation?

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
  }

  // MARK: - Layout

  open func layoutView() {
    layoutScrollView()
    layoutImageView()
    layoutGridView()
    layoutOverlayView()
  }

  // MARK: - Bind

  open func bindRx() {
    bindRatio()
    bindCrop()
    bindScrollViewGestures()
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
