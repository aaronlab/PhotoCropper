//
//  PhotoCropperFrameGridView.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/18.
//

import RxSwift
import SnapKit
import Then
import UIKit

/// PhotoCropperFrameGridView
open class PhotoCropperFrameGridView: UIView {
  // MARK: - Public Properties

  /// Content view
  public var gridLines = UIView()
    .then {
      $0.alpha = 0
    }

  // MARK: - Internal Properties

  internal var gridLinesWillShow = PublishSubject<Void>()
  internal var gridLinesWillHide = PublishSubject<Void>()

  // MARK: - Private Properties

  private var bag = DisposeBag()

  private var gridAnimationTimer: Timer?

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    layoutView()
    bindRx()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
    layoutView()
    bindRx()
  }

  deinit { bag = DisposeBag() }

  /// Configure all
  open func configure() {
    clipsToBounds = true
    configureBorder()
    configureView()
  }

  /// Layout view
  open func layoutView() {
    layoutContentView()
    layoutGrids()
  }

  /// Bind Rx
  open func bindRx() {
    bindGridLinesWillShow()
    bindGridLinesWillHide()
    bindCornerRadius()
  }
}

// MARK: - Configure

extension PhotoCropperFrameGridView {
  /// Configure border of the frame
  private func configureBorder() {
    let hideFrameBorder = PhotoCropper.shared.hideFrameBorder
    if hideFrameBorder { return }
    layer.borderWidth = PhotoCropper.shared.appearance.frameBorderWidth
    layer.borderColor = PhotoCropper.shared.appearance.frameColor.cgColor
  }

  /// Configure view
  private func configureView() {
    addSubview(gridLines)
  }
}

// MARK: - Layout

extension PhotoCropperFrameGridView {
  /// Layout content view
  private func layoutContentView() {
    gridLines.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  /// Layout girds
  private func layoutGrids() {
    let verticalGridStackView = UIStackView()
    verticalGridStackView.stylingGrid(.vertical)
    let numberOfGridLines = PhotoCropper.shared.numberOfGridLines

    for _ in 0 ..< numberOfGridLines {
      let horizontalGridStackView = UIStackView()
      horizontalGridStackView.stylingGrid(.horizontal)

      for _ in 0 ..< numberOfGridLines {
        let gridSubView = UIView()
        gridSubView.stylingGridSubView()
        horizontalGridStackView.addArrangedSubview(gridSubView)
      }

      verticalGridStackView.addArrangedSubview(horizontalGridStackView)
    }

    gridLines.addSubview(verticalGridStackView)

    verticalGridStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

// MARK: - Bind

extension PhotoCropperFrameGridView {
  private func bindGridLinesWillShow() {
    gridLinesWillShow
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.showGridLines()
      })
      .disposed(by: bag)
  }

  /// Show grid lines
  private func showGridLines() {
    if PhotoCropper.shared.hideGrid { return }

    if gridAnimationTimer != nil {
      gridAnimationTimer?.invalidate()
      gridAnimationTimer = nil
    }

    gridLines.show()
  }

  private func bindGridLinesWillHide() {
    gridLinesWillHide
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.hideGridLines()
      })
      .disposed(by: bag)
  }

  /// Hide grid lines
  private func hideGridLines() {
    if PhotoCropper.shared.hideGrid { return }

    let delay = PhotoCropper.shared.gridHideDelayDuration
    gridAnimationTimer?.invalidate()
    gridAnimationTimer = Timer.scheduledTimer(withTimeInterval: delay,
                                              repeats: false,
                                              block: { [weak self] timer in
                                                self?.gridLines.hide()
                                                timer.invalidate()
                                                self?.gridAnimationTimer = nil
                                              })
  }

  private func bindCornerRadius() {
    PhotoCropper.shared.appearance.cornerRadius
      .bind(to: layer.rx.cornerRadius)
      .disposed(by: bag)
  }
}

// MARK: - UIView

private extension UIView {
  /// Grid sub view style
  func stylingGridSubView() {
    backgroundColor = .clear
    layer.borderWidth = PhotoCropper.shared.appearance.gridWidth / 2
    layer.borderColor = PhotoCropper.shared.appearance.gridColor.cgColor
  }
}

private extension UIStackView {
  /// Grid style stack view
  func stylingGrid(_ axis: NSLayoutConstraint.Axis) {
    self.axis = axis
    spacing = 0
    distribution = .fillEqually
    alignment = .fill
  }
}
