//
//  SpinnerView.swift
//  yandex_trains_ios
//
//  Created by Alexandr Olferuk on 06/06/16.
//  Copyright © 2016 Valery Sukovykh. All rights reserved.
//

import UIKit
import Foundation

class SpinnerView: UIView, CAAnimationDelegate {
    
    //MARK: Properties
    @IBInspectable var circleRadius: CGFloat = 20
    
    @IBInspectable var lineWidth: CGFloat {
        get {
            return lineWidth_
        }
        set {
            lineWidth_ = newValue
            circlePathLayer.lineWidth = newValue
        }
    }
    
    @IBInspectable var color: UIColor {
        get {
            return color_
        }
        set {
            color_ = newValue
            circlePathLayer.strokeColor = newValue.CGColor
        }
    }
    
    @IBInspectable var animating: Bool {
        get {
            return isAnimating
        }
        set {
            isAnimating = newValue
            if newValue {
                animateRotation()
            }
        }
    }
    
    @IBInspectable var animationDuration: Double {
        get {
            return animationDuration_
        }
        set {
            animationDuration_ = newValue
            animateRotation()
        }
    }
    
    private var circleFrame: CGRect {
        get {
            var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
            circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
            circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
            return circleFrame
        }
    }
    
    private var circlePath: UIBezierPath {
        get {
            let path = UIBezierPath()
            let rect = circleFrame
            let center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
            path.addArcWithCenter(center, radius: rect.size.width/2.0, startAngle: CGFloat(3.0*M_PI/2.0), endAngle: CGFloat(M_PI/2.0), clockwise: true)
            return path
        }
    }
    
    private let circlePathLayer = CAShapeLayer()
    private let Key = "RotationAnimationKey"
    private let longEnough: Float = 100000
    
    private var lineWidth_: CGFloat = 4.0
    private var color_: UIColor = UIColor.grayColor()
    private var animationDuration_: Double = 0.7
    private var isAnimating: Bool = true
    
    //MARK: Lifecycle
    init() {
        super.init(frame: CGRectZero)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath.CGPath
        animateRotation()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animateRotation()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        animateRotation()
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        configure()
        animateRotation()
    }
    
    private func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = lineWidth
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = color.CGColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.clearColor()
        hidden = true
    }
    
    //MARK: Animation
    private func animateRotation() {
        if let _ = circlePathLayer.animationForKey(Key) {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.repeatCount = longEnough
        animation.duration = animationDuration_
        animation.fromValue = 0
        animation.toValue = 2*M_PI
        animation.delegate = self
        circlePathLayer.addAnimation(animation, forKey: Key)
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animateRotation()
    }
    
    //MARK: Public methods
    func start() {
        hidden = false
        animating = true
    }
    
    func stop() {
        hidden = true
        animating = false
    }
}
