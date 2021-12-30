//
//  PhotoCropperView+PanGestures.swift
//  PhotoCropper
//
//  Created by Aaron Lee on 2021/12/31.
//

import RxGesture
import RxSwift
import UIKit

// MARK: - Bind

extension PhotoCropperView {
  internal func bindEdgeButtonGestures() {
    bindTopLeftEdgeButtonPanGestureChanged()
    bindTopRightEdgeButtonPanGestureChanged()
    bindBottomleftEdgeButtonPanGestureChanged()
    bottomRightEdgeButtonPanGestureChanged()
    bindEdgeButtonPanGesturesEnded()
  }

  private func bindTopLeftEdgeButtonPanGestureChanged() {
    let observable = topLeftEdgeButton.panGesture(state: .changed)

    observable
      .toVoid()
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    observable
      .subscribe(onNext: { [weak self] sender in
        guard let self = self,
              let view = sender.view else {
          return
        }

        let translation = sender.translation(in: self)
        var newPoint: CGPoint = .zero

        self.updateLeftEdgeConstraints(prevConstant: self.topLeftEdgeButtonLeadingConstant,
                                       view: view,
                                       boundary: self.topRightEdgeButton,
                                       translation: translation,
                                       newTranslation: &newPoint)

        self.updateTopEdgeConstraints(prevConstant: self.topLeftEdgeButtonTopConstant,
                                      view: view,
                                      boundary: self.bottomLeftEdgeButton,
                                      translation: translation,
                                      newTranslation: &newPoint)

        sender.setTranslation(newPoint, in: self)
      })
      .disposed(by: bag)
  }

  private func bindTopRightEdgeButtonPanGestureChanged() {
    let observable = topRightEdgeButton.panGesture(state: .changed)

    observable
      .toVoid()
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    observable
      .subscribe(onNext: { [weak self] sender in
        guard let self = self,
              let view = sender.view else {
          return
        }

        let translation = sender.translation(in: self)
        var newPoint: CGPoint = .zero

        self.updateRightEdgeConstraints(prevConstant: self.topRightEdgeButtonTrailingConstant,
                                        view: view,
                                        boundary: self.topLeftEdgeButton,
                                        translation: translation,
                                        newTranslation: &newPoint)

        self.updateTopEdgeConstraints(prevConstant: self.topRightEdgeButtonTopConstant,
                                      view: view,
                                      boundary: self.bottomRightEdgeButton,
                                      translation: translation,
                                      newTranslation: &newPoint)

        sender.setTranslation(newPoint, in: self)
      })
      .disposed(by: bag)
  }

  private func bindBottomleftEdgeButtonPanGestureChanged() {
    let observable = bottomLeftEdgeButton.panGesture(state: .changed)

    observable
      .toVoid()
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    observable
      .subscribe(onNext: { [weak self] sender in
        guard let self = self,
              let view = sender.view else {
          return
        }
        let translation = sender.translation(in: self)
        var newPoint: CGPoint = .zero

        self.updateLeftEdgeConstraints(prevConstant: self.bottomLeftEdgeButtonLeadingConstant,
                                       view: view,
                                       boundary: self.bottomRightEdgeButton,
                                       translation: translation,
                                       newTranslation: &newPoint)

        self.updateBottomEdgeConstraints(prevConstant: self.bottomLeftEdgeButtonBottomConstant,
                                         view: view,
                                         boundary: self.topLeftEdgeButton,
                                         translation: translation,
                                         newTranslation: &newPoint)

        sender.setTranslation(newPoint, in: self)
      })
      .disposed(by: bag)
  }

  private func bottomRightEdgeButtonPanGestureChanged() {
    let observable = bottomRightEdgeButton.panGesture(state: .changed)

    observable
      .toVoid()
      .bind(to: gridView.gridLinesWillShow)
      .disposed(by: bag)

    observable
      .subscribe(onNext: { [weak self] sender in
        guard let self = self,
              let view = sender.view else {
          return
        }

        let translation = sender.translation(in: self)
        var newPoint: CGPoint = .zero

        self.updateRightEdgeConstraints(prevConstant: self.bottomRightEdgeButtonTrailingConstant,
                                        view: view,
                                        boundary: self.bottomLeftEdgeButton,
                                        translation: translation,
                                        newTranslation: &newPoint)

        self.updateBottomEdgeConstraints(prevConstant: self.bottomRightEdgeButtonBottomConstant,
                                         view: view,
                                         boundary: self.topRightEdgeButton,
                                         translation: translation,
                                         newTranslation: &newPoint)

        sender.setTranslation(newPoint, in: self)
      })
      .disposed(by: bag)
  }

  private func bindEdgeButtonPanGesturesEnded() {
    let endedObservable = Observable
      .of(topLeftEdgeButton.panGesture(state: .ended),
          topRightEdgeButton.panGesture(state: .ended),
          bottomLeftEdgeButton.panGesture(state: .ended),
          bottomRightEdgeButton.panGesture(state: .ended))
      .merge()

    endedObservable
      .toVoid()
      .bind(to: gridView.gridLinesWillHide)
      .disposed(by: bag)
  }
}

// MARK: - Gesture Helpers

extension PhotoCropperView {
  private func updateTopEdgeConstraints(prevConstant: CGFloat,
                                        view: UIView,
                                        boundary: UIView,
                                        translation: CGPoint,
                                        newTranslation: inout CGPoint) {
    let vEnabled = updateVerticalTopEdgesEnabled(in: view,
                                                 boundary: boundary,
                                                 translation: translation)
    let translatedOffset = translation.y + prevConstant
    let offset = max(translatedOffset, .zero)
    newTranslation.y = updateVerticalTopEdges(enabled: vEnabled,
                                              offset: offset,
                                              translation: translation)
  }

  private func updateRightEdgeConstraints(prevConstant: CGFloat,
                                          view: UIView,
                                          boundary: UIView,
                                          translation: CGPoint,
                                          newTranslation: inout CGPoint) {
    let hEnabled = updateHorizontalRightEdgesEnabled(in: view,
                                                     boundary: boundary,
                                                     translation: translation)
    let translatedOffset = translation.x + prevConstant
    let offset = min(translatedOffset, .zero)
    newTranslation.x = updateHorizontalRightEdges(enabled: hEnabled,
                                                  offset: offset,
                                                  translation: translation)
  }

  private func updateBottomEdgeConstraints(prevConstant: CGFloat,
                                           view: UIView,
                                           boundary: UIView,
                                           translation: CGPoint,
                                           newTranslation: inout CGPoint) {
    let vEnabled = updateVerticalBottomEdgesEnabled(in: view,
                                                    boundary: boundary,
                                                    translation: translation)
    let translatedOffset = translation.y + prevConstant
    let offset = min(translatedOffset, .zero)
    newTranslation.y = updateVerticalBottomEdges(enabled: vEnabled,
                                                 offset: offset,
                                                 translation: translation)
  }

  private func updateLeftEdgeConstraints(prevConstant: CGFloat,
                                         view: UIView,
                                         boundary: UIView,
                                         translation: CGPoint,
                                         newTranslation: inout CGPoint) {
    let hEnabled = updateHorizontalLeftEdgesEnabled(in: view,
                                                    boundary: boundary,
                                                    translation: translation)
    let translatedOffset = translation.x + prevConstant
    let offset = max(translatedOffset, .zero)
    newTranslation.x = updateHorizontalLeftEdges(enabled: hEnabled,
                                                 offset: offset,
                                                 translation: translation)
  }

  private func updateVerticalTopEdgesEnabled(in view: UIView,
                                             boundary: UIView,
                                             translation: CGPoint) -> Bool {
    let verticalMoveEnabled = view.frame.maxY < boundary.frame.minY
    let isVerticalRecovering = !verticalMoveEnabled && translation.y < 0
    return verticalMoveEnabled || isVerticalRecovering
  }

  private func updateHorizontalRightEdgesEnabled(in view: UIView,
                                                 boundary: UIView,
                                                 translation: CGPoint) -> Bool {
    let horizontalMoveEnabled = boundary.frame.maxX < view.frame.minX
    let isHorizontalRecovering = !horizontalMoveEnabled && translation.x > 0
    return horizontalMoveEnabled || isHorizontalRecovering
  }

  private func updateVerticalBottomEdgesEnabled(in view: UIView,
                                                boundary: UIView,
                                                translation: CGPoint) -> Bool {
    let verticalMoveEnabled = view.frame.minY > boundary.frame.maxY
    let isVerticalRecovering = !verticalMoveEnabled && translation.y > 0
    return verticalMoveEnabled || isVerticalRecovering
  }

  private func updateHorizontalLeftEdgesEnabled(in view: UIView,
                                                boundary: UIView,
                                                translation: CGPoint) -> Bool {
    let horizontalMoveEnabled = view.frame.maxX < boundary.frame.minX
    let isHorizontalRecovering = !horizontalMoveEnabled && translation.x < 0
    return horizontalMoveEnabled || isHorizontalRecovering
  }

  private func updateVerticalTopEdges(enabled: Bool,
                                      offset: CGFloat,
                                      translation: CGPoint) -> CGFloat {
    if enabled {
      topLeftEdgeButtonTop.update(offset: offset)
      topRightEdgeButtonTop.update(offset: offset)
      gridView.gridLines.snp.updateConstraints {
        $0.top.equalToSuperview().offset(offset)
      }

      if offset <= 0 {
        return translation.y
      }

      return .zero
    }

    return translation.y
  }

  private func updateVerticalBottomEdges(enabled: Bool,
                                         offset: CGFloat,
                                         translation: CGPoint) -> CGFloat {
    if enabled {
      bottomLeftEdgeButtonBottom.update(offset: offset)
      bottomRightEdgeButtonBottom.update(offset: offset)
      gridView.gridLines.snp.updateConstraints {
        $0.bottom.equalToSuperview().offset(offset)
      }

      if offset >= 0 {
        return translation.y
      }

      return .zero
    }

    return translation.y
  }

  private func updateHorizontalRightEdges(enabled: Bool,
                                          offset: CGFloat,
                                          translation: CGPoint) -> CGFloat {
    if enabled {
      topRightEdgeButtonTrailing.update(offset: offset)
      bottomRightEdgeButtonTrailing.update(offset: offset)
      gridView.gridLines.snp.updateConstraints {
        $0.trailing.equalToSuperview().offset(offset)
      }

      if offset >= 0 {
        return translation.y
      }

      return .zero
    }

    return translation.x
  }

  private func updateHorizontalLeftEdges(enabled: Bool,
                                         offset: CGFloat,
                                         translation: CGPoint) -> CGFloat {
    if enabled {
      topLeftEdgeButtonLeading.update(offset: offset)
      bottomLeftEdgeButtonLeading.update(offset: offset)
      gridView.gridLines.snp.updateConstraints {
        $0.leading.equalToSuperview().offset(offset)
      }

      if offset <= 0 {
        return translation.y
      }

      return .zero
    }

    return translation.x
  }
}

// MARK: - UIView

private extension UIView {}
