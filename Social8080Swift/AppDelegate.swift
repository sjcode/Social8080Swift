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
import MagicalRecord
import SlideMenuControllerSwift
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SirenDelegate {

    var window: UIWindow?
    
    var leftMenuViewController = SJLeftMenuViewController()
    var homeViewController = SJHomeViewController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //init database
        MagicalRecord.setupAutoMigratingCoreDataStack()
        MagicalRecord.setLoggingLevel(.Off)
        
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        
        //init cache
        let cache = NSURLCache.init(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let appearance = UINavigationBar.appearance()
        appearance.translucent = false
        appearance.shadowImage = UIImage()
        
        appearance.barTintColor = UIColor(hexString: "#3182D9")
        appearance.tintColor = UIColor.whiteColor()
        appearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(20)]
        
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        let nav = SJNavigationController(rootViewController: homeViewController)
        /*
        let drawerController = MMDrawerController.init(centerViewController: nav, leftDrawerViewController: leftMenuViewController)
        drawerController.openDrawerGestureModeMask = .None
        drawerController.closeDrawerGestureModeMask = .All
        drawerController.maximumLeftDrawerWidth = ScreenSize.SCREEN_WIDTH - 200

        drawerController.setDrawerVisualStateBlock { (drawerController, drawerSide, percentVisible) in
            let block = MMDrawerVisualState.slideVisualStateBlock()
            if block != nil{
                block(drawerController, drawerSide, percentVisible)
            }
        }
 */
        self.window!.rootViewController = nav
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

