//
//  SJPopUpViewControllerSwift.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/22.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

public class SJPopUpViewControllerSwift: UIViewController {

    lazy var blusView : UIVisualEffectView = {
        [unowned self] in
        let v = UIView()
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.7
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return blurEffectView
    }()
    
    lazy var popupView : UIView = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor(hexString: "#E8ECEE")
        v.frame = CGRectMake(0, 0, 300, 200)
        v.layer.cornerRadius = 5
        v.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        v.layer.borderWidth = 0.5
        v.center = self.view.center
        return v
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blusView)
        view.addSubview(popupView)
    }
    
    public func showInView(aView : UIView){
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
        //aView.addSubview(view)
        showAnimation()
    }
    
    public func showAnimation(){
        view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        view.alpha = 0
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.view.alpha = 1.0
            self!.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    public func hide(){
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            self!.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        }) { [weak self] (finished : Bool) in
            if finished{
                self!.view.removeFromSuperview()
            }
        }
    }
}
