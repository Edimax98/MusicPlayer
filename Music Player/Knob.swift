/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class Knob: UIControl {
  /** Contains the minimum value of the receiver. */
  var minimumValue: Float = 0

  /** Contains the maximum value of the receiver. */
  var maximumValue: Float = 1

  /** Contains the receiver’s current value. */
  private (set) var value: Float = 0

  /** Sets the receiver’s current value, allowing you to animate the change visually. */
  func setValue(_ newValue: Float, animated: Bool = false) {
    value = min(maximumValue, max(minimumValue, newValue))

    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue
    let angleValue = CGFloat(value - minimumValue) / CGFloat(valueRange) * angleRange + startAngle
    renderer.setPointerAngle(angleValue, animated: animated)
  }

  /** Contains a Boolean value indicating whether changes
   in the sliders value generate continuous update events. */
  var isContinuous = true

  private let renderer = KnobRenderer()

  /** Specifies the width in points of the knob control track. Defaults to 2 */
  var lineWidth: CGFloat {
    get { return renderer.lineWidth }
    set { renderer.lineWidth = newValue }
  }

  /** Specifies the angle of the start of the knob control track. Defaults to -11π/8 */
  var startAngle: CGFloat {
    get { return renderer.startAngle }
    set { renderer.startAngle = newValue }
  }

  /** Specifies the end angle of the knob control track. Defaults to 3π/8 */
  var endAngle: CGFloat {
    get { return renderer.endAngle }
    set { renderer.endAngle = newValue }
  }

  /** Specifies the length in points of the pointer on the knob. Defaults to 6 */
  var pointerLength: CGFloat {
    get { return renderer.pointerLength }
    set { renderer.pointerLength = newValue }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    renderer.updateBounds(bounds)
    renderer.trackColor = .blue
    renderer.pointerColor = .yellow
    renderer.setPointerAngle(renderer.startAngle)

    layer.addSublayer(renderer.trackLayer)
    layer.addSublayer(renderer.pointerLayer)

    let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(Knob.handleGesture(_:)))
    addGestureRecognizer(gestureRecognizer)
  }

  @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
    // 1
    let midPointAngle = (2 * CGFloat(Double.pi) + startAngle - endAngle) / 2 + endAngle
    // 2
    var boundedAngle = gesture.touchAngle
    if boundedAngle > midPointAngle {
      boundedAngle -= 2 * CGFloat(Double.pi)
    } else if boundedAngle < (midPointAngle - 2 * CGFloat(Double.pi)) {
      boundedAngle -= 2 * CGFloat(Double.pi)
    }

    // 3
    boundedAngle = min(endAngle, max(startAngle, boundedAngle))

    // 4
    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue
    let angleValue = Float(boundedAngle - startAngle) / Float(angleRange) * valueRange + minimumValue

    // 5
    setValue(angleValue)

    if isContinuous {
      sendActions(for: .valueChanged)
    } else {
      if gesture.state == .ended || gesture.state == .cancelled {
        sendActions(for: .valueChanged)
      }
    }
  }
}

private class KnobRenderer {
  
  var trackColor: UIColor = .purple {
    didSet {
      trackLayer.strokeColor = trackColor.cgColor
    }
  }
  
  var pointerColor: UIColor = .white {
    didSet {
      pointerLayer.strokeColor = pointerColor.cgColor
    }
  }
  
  var lineWidth: CGFloat = 2 {
    didSet {
      trackLayer.lineWidth = lineWidth
      pointerLayer.lineWidth = lineWidth
      updateTrackLayerPath()
      updatePointerLayerPath()
    }
  }

  var startAngle: CGFloat = CGFloat(Double.pi) * 0.0 {
    didSet {
      updateTrackLayerPath()
    }
  }

  var endAngle: CGFloat = CGFloat(Double.pi) / 3 {
    didSet {
      updateTrackLayerPath()
    }
  }
  
  var traceEndAngle: CGFloat = CGFloat(Double.pi)

  var pointerLength: CGFloat = 6 {
    didSet {
      updateTrackLayerPath()
      updatePointerLayerPath()
    }
  }

  private (set) var pointerAngle: CGFloat = 0.0 //CGFloat(Double.pi) * 11 / 8

  func setPointerAngle(_ newPointerAngle: CGFloat, animated: Bool = false) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle, 0, 0, 1)

    if animated {
      let midAngleValue = (max(newPointerAngle, pointerAngle) - min(newPointerAngle, pointerAngle)) / 2 + min(newPointerAngle, pointerAngle)
      let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      animation.values = [pointerAngle, midAngleValue, newPointerAngle]
      animation.keyTimes = [0.0, 0.5, 1.0]
      animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
      pointerLayer.add(animation, forKey: nil)
    }

    CATransaction.commit()

    pointerAngle = newPointerAngle
  }

  let trackLayer = CAShapeLayer()
  let pointerLayer = CAShapeLayer()

  init() {
    trackLayer.fillColor = UIColor.white.cgColor
    pointerLayer.fillColor = UIColor.yellow.cgColor
  }

  private func updateTrackLayerPath() {
    let bounds = trackLayer.bounds
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    let radius = min(bounds.width, bounds.height) / 2
    let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    trackLayer.path = ring.cgPath
  }
  
  private func updatePointerLayerPath() {
    let bounds = trackLayer.bounds
    let pointerRadius: CGFloat = 15
    let pointer = UIBezierPath(roundedRect: CGRect(x: bounds.width - pointerRadius / 2, y: bounds.midY, width: pointerRadius, height: pointerRadius), cornerRadius: pointerRadius)
      pointerLayer.path = pointer.cgPath
  }

  func updateBounds(_ bounds: CGRect) {
    trackLayer.bounds = bounds
    trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    updateTrackLayerPath()

    pointerLayer.bounds = trackLayer.bounds
    pointerLayer.position = trackLayer.position
    updatePointerLayerPath()
  }
}

import UIKit.UIGestureRecognizerSubclass

private class RotationGestureRecognizer: UIPanGestureRecognizer {
  private(set) var touchAngle: CGFloat = 0

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    updateAngle(with: touches)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    updateAngle(with: touches)
  }

  private func updateAngle(with touches: Set<UITouch>) {
    guard
      let touch = touches.first,
      let view = view
    else {
      return
    }
    let touchPoint = touch.location(in: view)
    touchAngle = angle(for: touchPoint, in: view)
  }

  private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
    let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY)
    return atan2(centerOffset.y, centerOffset.x)
  }

  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)

    maximumNumberOfTouches = 1
    minimumNumberOfTouches = 1
  }
}
