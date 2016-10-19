//
//  String+Extension.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var stringByRemovingWhitespaceAndNewlineCharacterSet: String {
        return componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).joinWithSeparator("")
    }
    
    func calculateWidth(font : UIFont) -> CGFloat{
        let size = (self as NSString).boundingRectWithSize(CGSize(width: CGFloat.max,height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return size.width
    }
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    subscript(r : NSRange) -> String{
        get{
            return (self as NSString).substringWithRange(r)
        }
    }
    
//    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: width, height: CGFloat.max)
//        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
//        return boundingBox.height
//    }
//    
    

}