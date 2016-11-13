//
//  SJProfileView.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import SnapKit

typealias ClickButtonAction = () -> ()

class SJProfileView: UIView {
    lazy var defaultavatar : UIImageView = {
        let v = UIImageView(image: UIImage.init(named: "default_avatar"))
        v.contentMode = .ScaleToFill
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 40
        v.layer.borderColor = UIColor.init(white: 1, alpha: 0.3).CGColor
        v.layer.borderWidth = 2
        return v
    }()
    
    lazy var loginbtn : UIButton = {
        let b = UIButton(type: .System)
        b.layer.cornerRadius = 5
        b.layer.masksToBounds = true
        b.layer.borderColor = UIColor.whiteColor().CGColor
        b.layer.borderWidth = 1
        b.backgroundColor = UIColor.clearColor()
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.titleLabel?.font = defaultFont(14)
        b.setTitle("登录", forState: .Normal)
        return b
    }()
    
    lazy var settingbtn : UIButton = {
        let b = UIButton(type: .System)
        b.layer.masksToBounds = true
        b.layer.cornerRadius = 5
        b.layer.borderColor = UIColor.whiteColor().CGColor
        b.layer.borderWidth = 1
        b.backgroundColor = UIColor.clearColor()
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.titleLabel?.font = defaultFont(14)
        b.setTitle("设置", forState: .Normal)
        b.hidden = true
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            
        })
        return b
    }()
    
    lazy var nickname : UILabel = {
        let l = UILabel()
        l.font = defaultFont(14)
        l.textColor = UIColor.whiteColor()
        l.textAlignment = .Center
        return l
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#3182D9")
        
        addSubview(defaultavatar)
        defaultavatar.snp_makeConstraints { [weak self] (make) in
            make.size.equalTo(ccs(80, 80))
            make.center.equalTo(self!)
        }
        addSubview(loginbtn)
        loginbtn.snp_makeConstraints { [weak self] (make) in
            make.size.equalTo(ccs(100, 25))
            make.centerX.equalTo(self!)
            make.top.equalTo(self!.defaultavatar.snp_bottom).offset(10)
        }
        
        addSubview(settingbtn)
        settingbtn.snp_makeConstraints { (make) in
            make.size.equalTo(ccs(100, 25))
            make.right.equalTo(-8)
            make.top.equalTo(35)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SJProfileViewAction {
    case Login,Settings
}

class SJProfileViewManager{
    var profileView : SJProfileView!
    var loginHandle : ClickButtonAction?
    var settingHandle : ClickButtonAction?
    func setupProfileAtContain(view : UIView, loginHandle : ClickButtonAction, settingHandle : ClickButtonAction){
        profileView = SJProfileView(frame: ccr(0,0,ScreenSize.SCREEN_WIDTH, 180))
        self.loginHandle = loginHandle
        self.settingHandle = settingHandle
        view.addSubview(profileView)
        profileView.loginbtn.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        profileView.settingbtn.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
    }
    
    @objc func buttonAction(sender : UIButton){
        if sender == profileView.loginbtn , let block = loginHandle {
            block()
        }else if sender == profileView.settingbtn , let block = settingHandle{
            block()
        }
    }
    
    func updateView(user : SJUserModel?){
        if let u = user{
            profileView.defaultavatar.kf_setImageWithURL(NSURL.init(string: u.bigavatarurl))
            profileView.nickname.text = "sexsexdog"
            profileView.loginbtn.hidden = true
            profileView.settingbtn.hidden = false
        }else{
            profileView.defaultavatar.image = UIImage.init(named: "default_avatar")
            profileView.nickname.text = ""
            profileView.loginbtn.hidden = false
            profileView.settingbtn.hidden = true
        }
    }
}
