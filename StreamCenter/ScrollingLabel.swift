//
//  UILabel.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ScrollingLabel: UIView {
    
    fileprivate var scrollSpeed = 0.5 {
        didSet {
            if scrollSpeed > 1 {
                scrollSpeed = 1
            } else if scrollSpeed < 0 {
                scrollSpeed = 0
            }
        }
    }
    fileprivate var textLayer = CATextLayer()
    fileprivate var gradientLayer = CAGradientLayer()
    fileprivate var isScrolling = false
    
    fileprivate var offset = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor.black
        super.init(frame: frame)
        self.setupLayers()
    }
    
    convenience init(scrollSpeed speed: Double) {
        self.init(frame: CGRect.zero)
        scrollSpeed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor.black
        super.init(coder: aDecoder)
        self.setupLayers()
    }
    
    func setupLayers() {
        self.clipsToBounds = true
        
        self.textLayer.string = "Hello World"
        self.textLayer.fontSize = 30
        self.textLayer.foregroundColor = UIColor.white.cgColor
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = 500
        self.textLayer.isWrapped = false
        self.textLayer.alignmentMode = kCAAlignmentLeft
        self.layer.addSublayer(self.textLayer)
        
        self.gradientLayer.colors = [
            UIColor(white: 0.4, alpha: 0).cgColor,
            UIColor(white: 0.4, alpha: 0.9).cgColor,
            UIColor.white.cgColor,
            UIColor(white: 0.4, alpha: 0.9).cgColor,
            UIColor(white: 0.4, alpha: 0).cgColor
        ]
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.gradientLayer.locations = [
            NSNumber(value: 0.0 as Double),
            NSNumber(value: 0.05 as Double),
            NSNumber(value: 0.5 as Double),
            NSNumber(value: 0.95 as Double),
            NSNumber(value: 1.0 as Double),
        ]
    }
    
    override func layoutSubviews() {
        self.textLayer.frame = self.bounds
        self.textLayer.frame.size.width = self.textLayer.preferredFrameSize().width
        self.gradientLayer.frame = self.bounds
    }
    
    /*
    * beginScrolling()
    *
    * tell the label to start scrolling
    *
    */
    func beginScrolling() {
        let bounds = self.bounds
        let size = textSize
        guard size.width > bounds.width && self.scrollSpeed > 0 else {
            return
        }
        let moveAmount = (size.width - bounds.width)
        let initialPoint = self.textLayer.position
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 10 * (1.1 - scrollSpeed)
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: initialPoint)
        animation.toValue = NSValue(cgPoint: CGPoint(x: initialPoint.x - (moveAmount + 5), y: initialPoint.y))
        self.textLayer.add(animation, forKey: nil)
        self.layer.mask = self.gradientLayer
        isScrolling = true
    }
    
    /*
    * endScrolling()
    *
    * tell the label to stop scrolling
    *
    */
    func endScrolling() {
        if !isScrolling {
            return
        }
        self.textLayer.removeAllAnimations()
        self.layer.mask = nil
        isScrolling = false
    }
    
    var font: UIFont {
        didSet {
            textLayer.font = font.fontName as CFTypeRef?
            textLayer.fontSize = font.pointSize
        }
    }
    
    var textColor: UIColor {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    
    var text: String? {
        didSet {
            self.textLayer.string = text
        }
    }
    
    var textSize: CGSize {
        get {
            return self.textLayer.preferredFrameSize()
        }
    }
}
