//
//  ChatMessageView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-23.

import UIKit
import Foundation


class ChatMessageView : UIView {
    let message : NSAttributedString
    
    init(message: NSAttributedString, width : CGFloat, position : CGPoint) {
        let maxSize = CGSize(width: width, height: 10000)
        let size = message.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        self.message = message

        super.init(frame: CGRect(origin: position, size: CGSize(width: width, height: size.height+10)))
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        self.message = NSAttributedString(string: "")
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        message.draw(in: rect)
    }
}
