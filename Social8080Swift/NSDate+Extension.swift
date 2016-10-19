//
//  NSDate+Extension.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation

extension NSDate{
    var stringFromDate : String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.stringFromDate(self)
    }
    
    static func dateFromString(string : String) -> NSDate{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.dateFromString(string)!
    }
}