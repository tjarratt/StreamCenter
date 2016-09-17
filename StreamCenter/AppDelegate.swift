//
//  AppDelegate.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.rootViewController = TwitchGamesViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

