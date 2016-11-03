//
//  SJPopUpViewControllerSwift.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/22.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

public class SJPopUpViewControllerSwift: UIViewController {
    lazy var blusView : UIVisualEffectView = { [unowned self] in
        let v = UIView()
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.3
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurEffectView.addGestureRecognizer(self.tap)
        return blurEffectView
    }()
    
    private lazy var tap : UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickBlurView(_:)))
        return tap
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
    
    lazy var reply : UIButton = {
        let b = UIButton(type: .Custom)
        //b.setImage(UIImage.init(named: "icon_thread_reply"), forState: .Normal)
        b.setTitle("回复", forState: .Normal)
        b.setTitleColor(UIColor(hexString : "#28384D"), forState: .Normal)
        return b
    }()
    
    lazy var favour : UIButton = {
        let b = UIButton(type: .Custom)
        //b.setImage(UIImage.init(named: "icon_thread_favour"), forState: .Normal)
        b.setTitle("收藏", forState: .Normal)
        b.setTitleColor(UIColor(hexString : "#28384D"), forState: .Normal)
        return b
    }()
    
    lazy var share : UIButton = {
        let b = UIButton(type: .Custom)
        //b.setImage(UIImage.init(named: "icon_thread_share"), forState: .Normal)
        b.setTitle("分享", forState: .Normal)
        b.setTitleColor(UIColor(hexString : "#28384D"), forState: .Normal)
        return b
    }()
    
    private lazy var cancel : UIButton = {
        let b = UIButton(type: .System)
        b.setTitleColor(UIColor(hexString : "#28384D"), forState: .Normal)
        b.setTitle("取消", forState: .Normal)
        b.titleLabel?.font = defaultFont(12)
        b.addTarget(self, action: #selector(cancelhandle(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let blurimage = UIImage.init(color: UIColor.init(white: 0.8, alpha: 1))!.applyBlurWithRadius(60, tintColor: UIColor.init(white: 0.8, alpha: 0.8), saturationDeltaFactor: 1.8)
//        let imageView = UIImageView(frame: view.bounds)
//        imageView.image = blurimage
//        view.addSubview(imageView)
//        
//        
        
        view.addSubview(blusView)

        popupView.addSubview(reply)
        reply.snp_makeConstraints { (make) in
            make.centerX.equalTo(popupView)
            make.top.equalTo(20)
        }
        popupView.addSubview(favour)
        favour.snp_makeConstraints { (make) in
            make.centerX.equalTo(popupView)
            make.top.equalTo(reply.snp_bottom).offset(5)
        }
        popupView.addSubview(share)
        share.snp_makeConstraints { (make) in
            make.centerX.equalTo(popupView)
            make.top.equalTo(favour.snp_bottom).offset(5)
        }
        
        popupView.addSubview(cancel)
        cancel.snp_makeConstraints { (make) in
            make.left.equalTo(3)
            make.top.equalTo(3)
        }
        view.addSubview(popupView)
    }
    
    func cancelhandle(sender : UIButton){
        hide()
    }
    
    func clickBlurView(gesture : UITapGestureRecognizer){
        hide()
    }
    
    func clickreply(sender : UIButton){
        dprint("hit")
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
