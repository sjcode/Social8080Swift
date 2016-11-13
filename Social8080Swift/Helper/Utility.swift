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

func ccs(width: CGFloat, _ height: CGFloat) -> CGSize{
    return CGSizeMake(width, height)
}

func ccr(x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRectMake(x, y, width, height)
}