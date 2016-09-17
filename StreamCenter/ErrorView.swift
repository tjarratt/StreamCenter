//
//  ErrorView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-16.

import UIKit
import Foundation

class ErrorView : UIView {
    
    fileprivate var imageView : UIImageView!
    fileprivate var label : UILabel!
    
    init(dimension: CGFloat, andTitle title : String) {
        super.init(frame: CGRect(x: 0, y: 0, width: dimension, height: dimension))
        
        let imageViewBounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width/1.333333333)
        imageView = UIImageView(frame: imageViewBounds)
        imageView.image = getErrorImageOfColor(UIColor.white)
        
        let labelBounds = CGRect(x: 0, y: imageViewBounds.height, width: imageViewBounds.width, height: self.bounds.height - imageViewBounds.height)
        label = UILabel(frame: labelBounds)
        label.text = title
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.font = label.font.withSize(25)
        
        self.addSubview(imageView)
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func getErrorImageOfColor(_ color : UIColor) -> UIImage {
        
        let size = CGSize(width: 300, height: 225)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        let pathRef = CGMutablePath()

        pathRef.move(to: CGPoint(x:215.577, y:189.5))
        pathRef.addLine(to: CGPoint(x: 243.506, y: 189.5))
        pathRef.addCurve(to: CGPoint(x: 298.5, y: 134.5),
                         control1: CGPoint(x: 273.878, y: 189.5),
                         control2: CGPoint(x: 298.5, y: 164.814))
        pathRef.addCurve(to: CGPoint(x: 264.211, y:83.521),
                         control1: CGPoint(x: 298.5, y: 111.439),
                         control2: CGPoint(x: 284.346, y: 91.694))
        pathRef.addLine(to: CGPoint(x: 264.211, y: 83.521))
        pathRef.addCurve(to: CGPoint(x: 205, y: 35.5),
                         control1: CGPoint(x: 258.46, y: 56.095),
                         control2: CGPoint(x: 234.135, y: 35.5))
        pathRef.addCurve(to: CGPoint(x: 178.532, y: 41.582),
                         control1: CGPoint(x: 195.508, y: 35.5),
                         control2: CGPoint(x: 186.527, y: 37.686))
        pathRef.addCurve(to: CGPoint(x: 111.5, y: 2.5),
                         control1: CGPoint(x: 165.303, y: 18.246),
                         control2: CGPoint(x: 140.24, y: 2.5))
        pathRef.addCurve(to: CGPoint(x: 34.5, y: 79.5),
                         control1: CGPoint(x: 68.974, y: 2.5),
                         control2: CGPoint(x: 34.5, y: 36.974))
        pathRef.addCurve(to: CGPoint(x: 34.631, y: 84.027),
                         control1: CGPoint(x: 34.5, y: 81.02),
                         control2: CGPoint(x: 34.544, y: 82.529))
        pathRef.addLine(to: CGPoint(x: 34.631, y: 84.027))
        pathRef.addCurve(to: CGPoint(x: 1.5, y: 134.5),
                         control1: CGPoint(x: 15.136, y: 92.498),
                         control2: CGPoint(x: 1.5, y: 111.94))
        pathRef.addCurve(to: CGPoint(x: 56.494, y: 189.5),
                         control1: CGPoint(x: 1.5, y: 164.876),
                         control2: CGPoint(x: 26.057, y: 189.5))

        pathRef.addLine(to: CGPoint(x: 84.423, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 150, y: 79.5))
        pathRef.addLine(to: CGPoint(x: 215.577, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 215.577, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 215.577, y: 189.5))
        pathRef.closeSubpath()

        pathRef.move(to: CGPoint(x: 150, y: 101.5))
        pathRef.addLine(to: CGPoint(x: 221.5, y: 222.5))
        pathRef.addLine(to: CGPoint(x: 78.5, y: 222.5))
        pathRef.addLine(to: CGPoint(x: 150, y: 101.5))
        pathRef.addLine(to: CGPoint(x: 150, y: 101.5))
        pathRef.closeSubpath()

        pathRef.move(to: CGPoint(x: 144.5, y: 145.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 178.5))
        pathRef.addLine(to: CGPoint(x: 155.5, y: 178.5))
        pathRef.addLine(to: CGPoint(x: 155.5, y: 145.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 145.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 145.5))
        pathRef.closeSubpath()

        pathRef.move(to: CGPoint(x: 144.5, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 200.5))
        pathRef.addLine(to: CGPoint(x: 155.5, y: 200.5))
        pathRef.addLine(to: CGPoint(x: 155.5, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 189.5))
        pathRef.addLine(to: CGPoint(x: 144.5, y: 189.5))
        pathRef.closeSubpath()
        
        ctx!.setFillColor(color.cgColor)
        ctx!.addPath(pathRef)
        ctx!.fillPath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
}
