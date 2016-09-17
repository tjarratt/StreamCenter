//
//  ModalMenuView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-25.

import UIKit
import Foundation

class ModalMenuView : UIView {
    let menuOptions : [String : [MenuOption]]
    let menuSize : CGSize
    let menuItemSize : CGSize
    var menuItemCount : Int {
        get {
            var count : Int = 0
            for menuOptionsArray in menuOptions {
                count += 1 + menuOptionsArray.1.count
            }
            return count
        }
    }
    
    init(frame: CGRect, options: [String : [MenuOption]], size : CGSize) {
        self.menuSize = size
        self.menuOptions = options
        self.menuItemSize = ModalMenuView.requiredMenuItemHeightToFit(menuOptions, menuSize: size)
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        self.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        self.buildMenuItemViews()
    }

    required init?(coder aDecoder: NSCoder) {
        self.menuSize = CGSize(width: 0, height: 0)
        self.menuItemSize = CGSize(width: 0, height: 0)
        self.menuOptions = [String : [MenuOption]]()
        super.init(coder: aDecoder)
    }
    
    static func requiredMenuItemHeightToFit(_ menuOptions : [String : [MenuOption]], menuSize : CGSize) -> CGSize {
        var count : CGFloat = 0
        for menuOptionsArray in menuOptions {
            count += CGFloat(1 + menuOptionsArray.1.count)
        }
        let reqHeight = (menuSize.height / count) * 0.8 //For padding
        return CGSize(width: menuSize.width, height: reqHeight)
    }
    
    func buildMenuItemViews() {
        var currentIndex = 0
        for (name, menuOptions) in self.menuOptions {
            let menuTitle = UILabel(frame: self.getFrameForItemAtIndex(currentIndex))
            
            menuTitle.text = name
            menuTitle.textAlignment = NSTextAlignment.center
            menuTitle.font = UIFont.systemFont(ofSize: self.menuItemSize.height * 0.8, weight: 0.5)
            menuTitle.textColor = UIColor.white
            
            self.addSubview(menuTitle)
            
            for menuOption in menuOptions {
                currentIndex += 1
                let optionView = MenuItemView(frame: self.getFrameForItemAtIndex(currentIndex),
                                              option: menuOption)
                
                self.addSubview(optionView)
            }
            currentIndex += 1
        }
    }
    
    func getFrameForItemAtIndex(_ index : Int) -> CGRect {
        
        var y = (self.bounds.height - (CGFloat(self.menuItemCount) * self.menuItemSize.height))/2 + CGFloat(index) * self.menuItemSize.height
        
        y -= (self.menuItemSize.height * 0.2)
        y = index == 0 ? y : y + (CGFloat(index) * (self.menuItemSize.height * 0.2))
        
        return CGRect(x: self.bounds.width/2 - self.menuSize.width/2,
            y: y,
            width: self.menuSize.width,
            height: self.menuItemSize.height)
    }
}

class MenuItemView : UIView {
    var option : MenuOption
    var title : UILabel!
    var gestureRecognizer : UITapGestureRecognizer?
    
    init(frame: CGRect, option: MenuOption) {
        self.option = option
        super.init(frame: frame)
        
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuItemView.handleSelect))
        self.gestureRecognizer!.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        self.addGestureRecognizer(self.gestureRecognizer!)
        
        
        self.title = UILabel(frame: self.bounds)
        
        self.title.text = self.option.isEnabled ? self.option.enabledTitle : self.option.disabledTitle
        self.title.textAlignment = NSTextAlignment.center
        self.title.font = UIFont.systemFont(ofSize: self.bounds.height * 0.7, weight: 0)
        self.title.textColor = UIColor.white
        
        self.isUserInteractionEnabled = true
        
        self.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
        self.addSubview(self.title!)
        self.layer.cornerRadius = self.bounds.height * 0.05
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.option = MenuOption(title: "", enabled: false, onClick: {_ in })
        super.init(coder: aDecoder)
    }
    
    func handleSelect() {
        self.option.clickCallback(self)
    }
    
    func isOptionEnabled() -> Bool {
        return self.option.isEnabled
    }
    
    func setOptionEnabled(_ enabled : Bool) {
        self.option.isEnabled = enabled
        self.title!.text = self.option.isEnabled ? self.option.enabledTitle : self.option.disabledTitle
    }
    
    override var canBecomeFocused : Bool {
        
        if self.option.disabledTitle != self.option.enabledTitle {
            return true
        }
        else {
            return !self.option.isEnabled
        }
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if(context.nextFocusedView == self){
            coordinator.addCoordinatedAnimations({
                
                self.title!.textColor = UIColor.black
                self.backgroundColor = UIColor.white
                
                let newFrame = CGRect(
                    x: self.bounds.origin.x - (self.bounds.width * 0.1)/2,
                    y: self.bounds.origin.y - (self.bounds.height * 0.1)/2,
                    width: self.bounds.width * 1.1,
                    height: self.bounds.height * 1.1)
                
                self.bounds = newFrame
                self.title!.frame = newFrame
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        else if(context.previouslyFocusedView == self) {
            coordinator.addCoordinatedAnimations({
                
                self.title!.textColor = UIColor.white
                self.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
                
                let newFrame = CGRect(
                    x: self.bounds.origin.x + ((self.bounds.width/1.1) * 0.1)/2,
                    y: self.bounds.origin.y + ((self.bounds.height/1.1) * 0.1)/2,
                    width: self.bounds.width / 1.1,
                    height: self.bounds.height / 1.1)
                
                self.bounds = newFrame
                self.title!.frame = newFrame
                
                self.layoutIfNeeded()
                },
                completion: nil
            )
        }
        
    }
}

struct MenuOption {
    let enabledTitle : String
    let disabledTitle : String
    var isEnabled : Bool
    var clickCallback : (_ sender: MenuItemView?)->()
    var parameters : [String : AnyObject]?
    
    init(enabledTitle : String, disabledTitle : String, enabled : Bool, parameters: [String : AnyObject]? = nil, onClick : @escaping (_ sender : MenuItemView?)->()) {
        self.enabledTitle = enabledTitle
        self.disabledTitle = disabledTitle
        self.isEnabled = enabled
        self.clickCallback = onClick
        self.parameters = parameters
    }
    
    init(title : String, enabled : Bool, parameters: [String : AnyObject]? = nil, onClick : @escaping (_ sender : MenuItemView?)->()) {
        self.enabledTitle = title
        self.disabledTitle = title
        self.isEnabled = enabled
        self.clickCallback = onClick
        self.parameters = parameters
    }
    
}
