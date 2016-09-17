//
//  CellView.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/8/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

protocol CellItem {
    var urlTemplate: String? { get }
    var title: String { get }
    var subtitle: String { get }
    var bannerString: String? { get }
    var image: UIImage? { get }
    mutating func setImage(_ image: UIImage)
}

class ItemCellView: UICollectionViewCell {
    internal static let CELL_IDENTIFIER : String = "kItemCellView"
    internal static let LABEL_HEIGHT : CGFloat = 40
    
    fileprivate var representedItem : CellItem?
    fileprivate var image : UIImage?
    fileprivate var imageView : UIImageView!
    fileprivate var activityIndicator : UIActivityIndicatorView!
    fileprivate var titleLabel : ScrollingLabel!
    fileprivate var subtitleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageViewFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-80)
        self.imageView = UIImageView(frame: imageViewFrame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.adjustsImageWhenAncestorFocused = true
        //we don't need to have this next line because we are turning on the 'adjustsImageWhenAncestorFocused' therefore we can't clip to bounds, and the corner radius has no effect if we aren't clipping
        self.imageView.layer.cornerRadius = 10
        self.imageView.backgroundColor = UIColor(white: 0.25, alpha: 0.7)
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        self.activityIndicator = UIActivityIndicatorView(frame: imageViewFrame)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.startAnimating()
        
        self.titleLabel = ScrollingLabel(scrollSpeed: 0.5)
        self.subtitleLabel = UILabel()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.alpha = 0.5
        self.subtitleLabel.alpha = 0.5
        self.titleLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightSemibold)
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin)
        self.titleLabel.textColor = UIColor.white
        self.subtitleLabel.textColor = UIColor.white
        
        self.imageView.addSubview(self.activityIndicator)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        
        let viewDict = ["image" : imageView,
                        "title" : titleLabel,
                        "subtitle" : subtitleLabel,
                        "imageGuide" : imageView.focusedFrameGuide]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subtitle]|", options: [], metrics: nil, views: viewDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]", options: [], metrics: nil, views: viewDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageGuide]-5-[title(\(ItemCellView.LABEL_HEIGHT))]-5-[subtitle(\(ItemCellView.LABEL_HEIGHT))]|", options: [], metrics: nil, views: viewDict))
        
        self.imageView.addCenterConstraints(toView: self.activityIndicator)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    * prepareForReuse()
    *
    * Override the default method to free internal ressources and add
    * a loading indicator
    */
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.representedItem = nil
        self.image = nil
        self.imageView.image = nil
        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.imageView.frame)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.startAnimating()
        
        self.imageView.addSubview(self.activityIndicator!)
    }
    
    /*
    * assignImageAndDisplay()
    *
    * Downloads the image from the actual game and assigns it to the image view
    * Removes the loading indicator on download callback success
    */
    fileprivate func assignImageAndDisplay() {
        self.downloadImageWithSize(self.imageView!.bounds.size) {
            (image, error) in
            
            if let image = image {
                self.image = image
            } else {
                self.image = nil
            }
            
            
            DispatchQueue.main.async(execute: {
                if self.activityIndicator != nil  {
                    self.activityIndicator?.removeFromSuperview()
                    self.activityIndicator = nil
                }
                self.imageView.image = self.image
            })
            
        }
    }
    
    /*
    * downloadImageWithSize(size : CGSize, completionHandler : (image : UIImage?, error : NSError?) -> ())
    *
    * Download an image from twitch server with the required size
    * Passes the downloaded image to a defined completion handler
    */
    fileprivate func downloadImageWithSize(_ size : CGSize, completionHandler : @escaping (_ image : UIImage?, _ error : NSError?) -> ()) {
        if let image = representedItem?.image {
            completionHandler(image, nil)
            return
        }
        if let imgUrlTemplate = representedItem?.urlTemplate {
            let imgUrlString = imgUrlTemplate.replacingOccurrences(of: "{width}", with: "\(Int(size.width))")
                .replacingOccurrences(of: "{height}", with: "\(Int(size.height))")
            let request = Alamofire.request(imgUrlString)
            request.response(completionHandler: { (response) in
                guard let data = response.data, let image = UIImage(data: data) else {
                    completionHandler(nil, nil)
                    return
                }
                self.representedItem?.setImage(image)
                completionHandler(image, nil)
            })
        }
    }
    
    /*
    * didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    *
    * Responds to the focus update by either growing or shrinking
    *
    */
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if(context.nextFocusedView == self){
            coordinator.addCoordinatedAnimations({
                self.titleLabel.alpha = 1
                self.subtitleLabel.alpha = 1
                self.titleLabel.beginScrolling()
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                self.titleLabel.alpha = 0.5
                self.subtitleLabel.alpha = 0.5
                self.titleLabel.endScrolling()
                },
                completion: nil
            )
        }
    }
    
    var centerVerticalCoordinate: CGFloat {
        get {
            switch representedItem {
            case is TwitchGame:
                return 40
            case is TwitchStream:
                return 22
            default:
                return 22
            }
        }
    }
    
    /////////////////////////////
    // MARK - Getter and setters
    /////////////////////////////
    
    func getRepresentedItem() -> CellItem? {
        return self.representedItem
    }
    
    func setRepresentedItem(_ item : CellItem) {
        self.representedItem = item
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        self.assignImageAndDisplay()
    }
    
}
