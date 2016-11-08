//
//  AppDelegate.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import AlamofireNetworkActivityIndicator
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SirenDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let appearance = UINavigationBar.appearance()
        appearance.translucent = false
        appearance.barTintColor = UIColor(hexString: "#28384D")
        appearance.tintColor = UIColor.whiteColor()
        appearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:defaultFont(14)]
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        self.window!.rootViewController = SJRootTabBarController()
        self.window!.makeKeyAndVisible()
        
        setupSiren()
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        Siren.sharedInstance.checkVersion(.Immediately)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Siren.sharedInstance.checkVersion(.Daily)
    }
    
    func setupSiren() {
        let siren = Siren.sharedInstance
        siren.forceLanguageLocalization = .ChineseSimplified
        siren.delegate = self
        siren.majorUpdateAlertType = .Force
        siren.minorUpdateAlertType = .Option
        siren.patchUpdateAlertType = .Skip
        siren.revisionUpdateAlertType = .Skip
        siren.countryCode = "CN"
        siren.checkVersion(.Immediately)
    }
    
    func sirenUserDidLaunchAppStore() {
        dprint(#function)
    }
}

