//
//  SJNavigationController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJNavigationController: UINavigationController {
//    override func pushViewController(viewController: UIViewController, animated: Bool) {
//        hidesBottomBarWhenPushed = true
//        super.pushViewController(viewController, animated: animated)
//    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
}
