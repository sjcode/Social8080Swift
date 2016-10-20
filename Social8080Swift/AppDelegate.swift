//
//  AppDelegate.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = UIColor(hexString: "#28384D")
        appearance.tintColor = UIColor.whiteColor()
        appearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(14)]
        /*
         [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
         NSFontAttributeName:[UIFont fontWithName:@"HoeflerText-Italic" size:32]};
         */
        
        
        let rootTabBarController = SJRootTabBarController()
        let leftViewController = SJLeftMenuViewController()
        let slideMenuController = SJSlideMenuController(mainViewController: rootTabBarController, leftMenuViewController: leftViewController)
        
        self.window!.rootViewController = slideMenuController
        self.window!.makeKeyAndVisible()
        return true
    }
}

