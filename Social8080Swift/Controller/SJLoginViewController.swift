//
//  SJLoginViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/21.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import FLAnimatedImage
import MBProgressHUD

class SJLoginViewController: SJViewController {
    
    private var token : NSDictionary?
    private lazy var backButton : UIButton = { [unowned self] in
        let b = UIButton.init(type: .Custom)
        b.setImage(UIImage.init(named: "back_normal"), forState: .Normal)
        b.setImage(UIImage.init(named: "back_highlight"), forState: .Highlighted)
        b.sizeToFit()
        b.addTarget(self, action: #selector(clickback(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var avatarImageView : UIImageView = {
        let v = UIImageView(image: UIImage.init(named: "default_avatar"))
        return v
    }()
    
    private lazy var username : UITextField = { [unowned self] in
        let f = UITextField()
        f.attributedPlaceholder = NSAttributedString(string:"用户名",
                                                            attributes:[NSForegroundColorAttributeName: UIColor(hexString: "ffffff", alpha: 0.2)!])
        f.text = "sexsexdog@163.com"
        f.delegate = self
        f.borderStyle = .None
        f.autocorrectionType = .No
        f.autocapitalizationType = .Words
        f.font = UIFont.systemFontOfSize(18)
        f.textColor = UIColor(hexString: "ffffff", alpha: 0.8)
        f.returnKeyType = .Next
        f.enablesReturnKeyAutomatically = true
        return f
    }()
    
    private lazy var password : UITextField = { [unowned self] in
        let f = UITextField()
        f.attributedPlaceholder = NSAttributedString(string:"密码",
                                                            attributes:[NSForegroundColorAttributeName: UIColor(hexString: "ffffff", alpha: 0.2)!])
        f.borderStyle = .None
        f.delegate = self
        f.text = "g6m8c6n3"
        f.secureTextEntry = true
        f.autocorrectionType = .No
        f.autocapitalizationType = .Words
        f.font = UIFont.systemFontOfSize(18)
        f.textColor = UIColor(hexString: "ffffff", alpha: 0.8)
        f.returnKeyType = .Next
        f.enablesReturnKeyAutomatically = true
        return f
    }()
    
    private lazy var seccode : UITextField = { [unowned self] in
        let f = UITextField()
        f.attributedPlaceholder = NSAttributedString(string:"验证码",
                                                     attributes:[NSForegroundColorAttributeName: UIColor(hexString: "ffffff", alpha: 0.2)!])
        f.borderStyle = .None
        f.delegate = self
        f.autocorrectionType = .No
        f.autocapitalizationType = .Words
        f.font = UIFont.systemFontOfSize(18)
        f.textColor = UIColor(hexString: "ffffff", alpha: 0.8)
        f.returnKeyType = .Go
        f.enablesReturnKeyAutomatically = true
        return f
    }()
    
    private lazy var secretImage : FLAnimatedImageView = { [unowned self] in
        let v = FLAnimatedImageView(image: UIImage.init(named: "loadingImage_50x118"))
        v.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clicksecret(_:)))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var loginbutton : UIButton = { [unowned self] in
        let b = UIButton.init(type: .Custom)
        b.layer.cornerRadius = 3
        b.backgroundColor = UIColor(hexString: "#3182D9")
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.setTitleColor(UIColor(hexString: "#B0B6BB"), forState: .Highlighted)
        b.setTitle("登录", forState: .Normal)
        b.addTarget(self, action: #selector(clickLogin(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var accountPancel : UIView = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor.init(white : 1, alpha: 0.1)
        let person = UIImageView(image: UIImage.init(named: "icon_login_user"))
        v.addSubview(person)
        person.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(12)
            make.top.equalTo(v).offset(20)
            make.size.equalTo(CGSizeMake(20,20))
        })
        
        v.addSubview(self.username)
        self.username.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(person.snp_right).offset(10)
            make.right.equalTo(v).offset(-5)
            make.height.equalTo(30)
            make.centerY.equalTo(person)
        })
        let divide = UIView()
        divide.backgroundColor = UIColor(hexString: "ffffff", alpha: 0.2)!
        v.addSubview(divide)
        divide.snp_makeConstraints(closure: { [weak self] (make) in
            make.left.equalTo(self!.username.snp_left)
            make.right.equalTo(v)
            make.centerY.equalTo(v)
            make.height.equalTo(0.5)
        })
        let lock = UIImageView.init(image: UIImage.init(named: "icon_login_password"))
        v.addSubview(lock)
        lock.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(12)
            make.top.equalTo(divide).offset(15)
            make.size.equalTo(CGSizeMake(20,20))
        })
        v.addSubview(self.password)
        self.password.snp_makeConstraints(closure : {(make) in
            make.left.equalTo(lock.snp_right).offset(10)
            make.right.equalTo(v).offset(-5)
            make.height.equalTo(30)
            make.centerY.equalTo(lock)
        })
        return v
    }()
    
    private lazy var secPanel : UIView = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor.init(white : 1, alpha: 0.1)
        let secimage = UIImageView(image: UIImage.init(named: "icon_login_seccode"))
        v.addSubview(secimage)
        secimage.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(12)
            make.centerY.equalTo(v)
            make.size.equalTo(CGSizeMake(20,20))
        })
        v.addSubview(self.seccode)
        self.seccode.snp_makeConstraints(closure : {(make) in
            make.left.equalTo(secimage.snp_right).offset(10)
            make.right.equalTo(v).offset(-50)
            make.height.equalTo(30)
            make.centerY.equalTo(secimage)
        })
        v.addSubview(self.secretImage)
        self.secretImage.snp_makeConstraints(closure: {(make) in
            make.right.equalTo(v).offset(-10)
            make.centerY.equalTo(v)
            make.height.equalTo(30)
            make.width.equalTo(80)
        })
        v.addSubview(self.progress)
        self.progress.snp_makeConstraints(closure : {[weak self](make) in
            make.right.equalTo(self!.secretImage.snp_left).offset(-3)
            make.centerY.equalTo(self!.secretImage)
        })
        
        
        return v
    }()
    
    private lazy var progress : UIActivityIndicatorView = {
        let p = UIActivityIndicatorView()
        p.hidesWhenStopped = true
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bkImage = UIImage.init(named: "login_bg")?.resizedImageWithBounds(view.bounds.size)
        view.backgroundColor = UIColor.init(patternImage: bkImage!)
        
        view.addSubview(backButton)
        view.addSubview(avatarImageView)
        view.addSubview(accountPancel)
        view.addSubview(secPanel)
        view.addSubview(loginbutton)
        
        backButton.snp_makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(5)
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
        }
        
        accountPancel.snp_makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp_bottom).offset(20)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(100)
        }
        
        secPanel.snp_makeConstraints { (make) in
            make.top.equalTo(accountPancel.snp_bottom).offset(5)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(50)
        }
        
        loginbutton.snp_makeConstraints { (make) in
            make.top.equalTo(secPanel.snp_bottom).offset(5)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(30)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadSecCodeImage()
    }
    
    //MARK: Action
    func clickback(sender : UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func clicksecret(sender : UITapGestureRecognizer){
        loadSecCodeImage()
    }
    
    func loadSecCodeImage(){
        secretImage.image = UIImage.init(named: "loadingImage_50x118")
        do{
            try NSFileManager.defaultManager().removeItemAtPath(dp("seccode.gif"))
        }catch{
            dprint("seccode.gif not exist.")
        }
        progress.startAnimating()
        SJClient.sharedInstance.tryLoginAndLoadUI(true) { [weak self](finish, error, uid) in
            dprint("ok")
            let imagefile = dp("seccode.gif")
            if let imagedata = NSData(contentsOfFile: imagefile) {
                let gif = FLAnimatedImage(animatedGIFData: imagedata)
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self!.progress.stopAnimating()
                    self!.secretImage.animatedImage = gif
                })
            }
        }
    }
    
    func clickLogin(sender : UIButton){        
        view.endEditing(true)
        
        if username.text?.characters.count == 0{
            alertmessage(view, message: "用户名不能为空")
            return
        }
        
        if password.text?.characters.count == 0{
            alertmessage(view, message: "密码不能为空")
            return
        }
        
        if seccode.text?.characters.count == 0{
            alertmessage(view, message: "验证码不能为空")
            return
        }
        
        
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.label.text = "登陆中..."
        SJClient.sharedInstance.doLoginWithUsername(username.text!, password: password.text!, secode: seccode.text!, completed:{ [weak self] finished ,error, uid in
            
            if finished{
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationLoginSuccess, object: self, userInfo: ["uid":uid!])
                self!.dismissViewControllerAnimated(true, completion: nil)
            }else{
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.label.text = error!.userInfo["message"] as? String
            }
            progressHUD.hideAnimated(true, afterDelay: 1)
        })
    }
}

extension SJLoginViewController : UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.seccode {
            self.clickLogin(self.loginbutton)
            return true
        }else if textField == self.username{
            self.password.becomeFirstResponder()
            return true
        }else if textField == self.password{
            self.seccode.becomeFirstResponder()
            return true
        }
        return false
    }
}
