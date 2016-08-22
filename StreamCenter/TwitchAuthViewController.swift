//
//  TwitchAuthViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class TwitchAuthViewController: QRCodeViewController {
    
    var UUID: String!
    
    convenience init() {
        let title = "Scan the QR code below or go to the link provided.\nOnce you have received your authentication code, enter it below."
        let uuid = String.randomStringWithLength(12)
        self.init(title: title, url: "http://streamcenterapp.com/oauth/twitch/\(uuid)")
        UUID = uuid
    }

    override func processCode() {
        guard let code = codeField.text else {
            Logger.Error("No code")
            return
        }
        
        StreamCenterService.authenticateTwitch(withCode: code, andUUID: UUID) { (token, error) -> () in
            Logger.Debug("Token: \(token)")
            guard let token = token else {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.titleLabel.textColor = UIColor.red
                    if let error = error {
                        self.titleLabel.text = "\(error.errorDescription)\nPlease ensure that your code is correct and press 'Process' again."
                    } else {
                        self.titleLabel.text = "An unknown error occured.\nPlease ensure that your code is correct and press 'Process' again."
                    }
                })
                return
            }
            TokenHelper.storeTwitchToken(token)
            self.delegate?.qrCodeViewControllerFinished(true, data: nil)
        }
    }

}
