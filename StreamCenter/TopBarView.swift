//
//  TopBarView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-15.

import UIKit
import Foundation

class TopBarView : UIVisualEffectView {
    fileprivate var titleView : UIView!
    
    init (frame : CGRect, withMainTitle title : String?, centerView: UIView? = nil, leftView: UIView? = nil, rightView: UIView? = nil) {
        let effect = UIBlurEffect(style: .dark)
        super.init(effect: effect)
    
        if let centerView = centerView {
            //just make sure that translatesAutoresizingMaskIntoConstraints is set to false because it is required to be false for autolayout
            centerView.translatesAutoresizingMaskIntoConstraints = false
            self.titleView = centerView
        } else {
            //Place title
            let titleLabel = UILabel(frame: CGRect.zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.font = UIFont(name: "Helvetica", size: 50)
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.textColor = UIColor.white
            titleLabel.adjustsFontSizeToFitWidth = true
            
            self.titleView = titleLabel
        }
        
        self.contentView.addSubview(self.titleView)
        
        if let leftView = leftView {
            leftView.translatesAutoresizingMaskIntoConstraints = false
            let viewDict = ["title" : titleView, "left" : leftView] as [String: UIView]

            self.contentView.addSubview(leftView)
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[left]->=15-[title]", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=10-[left]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: leftView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        }
        
        if let rightView = rightView {
            rightView.translatesAutoresizingMaskIntoConstraints = false
            let viewDict = ["title" : titleView, "right" : rightView] as [String : UIView]
            self.contentView.addSubview(rightView)
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 0.275, constant: 1.0))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[title]->=15-[right]-30-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=10-[right]->=10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: rightView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        }
        
        let viewDict = ["title" : titleView] as [String: UIView]
        if leftView == nil && rightView == nil {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[title]-10-|", options: [], metrics: nil, views: viewDict))
        } else {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[title]-10-|", options: [], metrics: nil, views: viewDict))
            self.contentView.addConstraint(NSLayoutConstraint(item: self.titleView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
