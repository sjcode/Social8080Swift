//
//  GlobalDefined.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/31.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import UIKit

func defaultFont(fontSize : CGFloat) -> UIFont{
    return UIFont.init(name: ".PingFang-SC-Light", size: fontSize)!
}

func boldFont(fontSize : CGFloat) -> UIFont{
    return UIFont.init(name: ".PingFangSC-Semibold", size: fontSize)!
}

func appdelegate() -> AppDelegate{
    let appdelegate = UIApplication.sharedApplication().delegate
    return appdelegate as! AppDelegate
}