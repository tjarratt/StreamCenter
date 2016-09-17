//
//  QRCodeViewController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

protocol QRCodeDelegate {
    func qrCodeViewControllerFinished(_ success: Bool, data: [String : AnyObject]?)
}

class QRCodeViewController: UIViewController {
    
    let codeField = UITextField()
    let titleLabel = UILabel()
    
    var delegate: QRCodeDelegate?
    
    init(title: String, url: String) {
        super.init(nibName: nil, bundle: nil)
        
        let authenticationUrlString = url
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont.systemFont(ofSize: 45, weight: UIFontWeightSemibold)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.text = title
        
        let image = QRCodeGenerator.generateQRCode(withString: authenticationUrlString, clearBackground: true)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightSemibold)
        label.textAlignment = NSTextAlignment.center
        label.text = authenticationUrlString
        
        self.codeField.translatesAutoresizingMaskIntoConstraints = false
        self.codeField.placeholder = "Enter your code here"
        
        let authButton = UIButton(type: .system)
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.addTarget(self, action: #selector(QRCodeViewController.processCode), for: .primaryActionTriggered)
        authButton.setTitle("Process", for: UIControlState())
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(QRCodeViewController.cancel), for: .primaryActionTriggered)
        cancelButton.setTitle("Cancel", for: UIControlState())
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        self.view.addSubview(codeField)
        self.view.addSubview(authButton)
        self.view.addSubview(cancelButton)
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.3, constant: 1.0))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: -90.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1.0, constant: -30.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.codeField, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.codeField, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: authButton, attribute: .top, relatedBy: .equal, toItem: self.codeField, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: authButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: authButton, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func cancel() {
        self.codeField.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func processCode() {
        //do nothing
        return
    }
}
