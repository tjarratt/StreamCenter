//
//  AppDelegate.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = SourceTabController()
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

