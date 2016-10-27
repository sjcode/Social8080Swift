//
//  SJTabBarController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import SwiftHEXColors

class SJTabBarController: UITabBarController {
    
    override func shouldAutorotate() -> Bool {
        if let viewController = self.selectedViewController{
            return viewController.shouldAutorotate()
        }else{
            return false
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let viewController = self.selectedViewController{
            return viewController.supportedInterfaceOrientations()
        }else{
            return .Portrait
        }
    }
}
