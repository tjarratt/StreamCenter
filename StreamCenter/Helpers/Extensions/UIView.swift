//
//  UIView.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/16/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addCenterConstraints(toView view: UIView) {
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    
}
