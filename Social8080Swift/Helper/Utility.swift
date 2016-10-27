//
//  Utility.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import MBProgressHUD

func extractByRegex(string : String, pattern : String) -> String{
    let regex = try! NSRegularExpression(pattern:pattern,options: .CaseInsensitive)
    
    let results = regex.matchesInString(string, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, string.characters.count))
    
    if results.count == 1{
        let match = results[0]
        let range1 = match.rangeAtIndex(1)
        return string[range1]
    }
    
    return ""
}

func getAvatarUrl(uid : String) -> String{
    let uid = Int(uid)!
    
    let a = uid/10000%10000
    let b = uid/100%100
    let c = uid%100
    
    return String(format: "http://bbs.8080.net/uc_server/data/avatar/000/%02d/%02d/%02d_avatar_small.jpg",a,b,c)
}

/*
 #define dp(filename) [([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]) stringByAppendingPathComponent:filename]
 */

func dp(filename : String) -> String{
    let file : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
    return file.stringByAppendingPathComponent(filename)
}

func alertmessage(aView : UIView, message : String){
    let progressHUD = MBProgressHUD.showHUDAddedTo(aView, animated: true)
    progressHUD.mode = .Text
    progressHUD.detailsLabelText = message
    progressHUD.margin = 10.0
    progressHUD.yOffset = 160.0
    progressHUD.removeFromSuperViewOnHide = true
    progressHUD.hide(true, afterDelay: 1)
}

func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    
    UIGraphicsBeginImageContext(imageView.bounds.size)
    layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage
}