//
//  ChatTopView.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/21/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class ChatTopView: UILabel {
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        
        text = title
        
        adjustsFontSizeToFitWidth = true
        
        textColor = UIColor.white
        backgroundColor = UIColor(hexString: "#555555")
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 30)
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 15)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        
    }
    
}
