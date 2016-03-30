//
//  SourceTabController.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/14/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class SourceTabController: UITabBarController {
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)

        let twitch = TwitchGamesViewController()
        
        setViewControllers([twitch], animated: false)
        
        self.tabBar.barTintColor = UIColor.blackColor()
    }
}
