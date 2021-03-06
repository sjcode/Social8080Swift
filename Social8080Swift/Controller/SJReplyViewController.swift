//
//  SJReplyViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/3.
//  Copyright © 2016年 sujian. All rights reserved.
//


import UIKit
import KMPlaceholderTextView
import IQKeyboardManagerSwift
import MBProgressHUD

class SJReplyViewController: SJViewController {
    var fid : Int!
    var tid : Int!
    var post : SJPostModel?
    var replyform : SJReplyFormModel?
    var sec : SJSecCodeModel?
    private lazy var textView : KMPlaceholderTextView = { [unowned self] in
        let v = KMPlaceholderTextView(frame : ccr(0, 0, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds)))
        v.placeholder = "此刻我正在想对Ta说些什么..."
        v.keyboardAppearance = .Dark
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.font = defaultFont(14)
        v.textColor = UIColor.grayColor()
        v.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        v.delegate = self
        return v
    }()
    
    private lazy var reply : UIButton = {
        let b = UIButton(type: .System)
        b.setTitle("回复", forState: .Normal)
        b.sizeToFit()
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.enabled = false
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.sendReply()
        })
        return b
    }()
    
    private lazy var secImageView : UIImageView = {
        let v = UIImageView(image: UIImage.init(named: "loadingImage_50x118"))
        v.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clicksecret))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var sectextfield : UITextField = {
        let t = UITextField()
        t.placeholder = "请输入验证码"
        t.font = defaultFont(12)
        t.backgroundColor = UIColor.whiteColor()
        t.autocapitalizationType = .None
        t.autocorrectionType = .No
        t.keyboardType = .ASCIICapable
        t.keyboardAppearance = .Dark
        t.textColor = UIColor.grayColor()
        t.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        t.layer.borderWidth = 0.5
        return t
    }()
    
    private lazy var secPanel : UIView = { [unowned self] in
        let v = UIView(frame: ccr(0, CGRectGetHeight(self.view.bounds) - 35, ScreenSize.SCREEN_WIDTH, 35 ))
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        v.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        let divide = UIView()
        divide.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        divide.frame = ccr(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        v.addSubview(self.secImageView)
        self.secImageView.snp_makeConstraints(closure : { [weak self] (make) in
            make.size.equalTo(ccs(80, 30))
            make.left.equalTo(8)
            make.centerY.equalTo(v)
            })
        
        v.addSubview(self.sectextfield)
        self.sectextfield.snp_makeConstraints(closure : { [weak self] (make) in
            make.size.equalTo(ccs(80, 30))
            make.left.equalTo(self!.secImageView.snp_right).offset(3)
            make.centerY.equalTo(v)
            })
        
        return v
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        if let name = post?.author{
            title = "回复 \(name)"
        }
        
        let rightBar = UIBarButtonItem(customView: reply)
        navigationItem.rightBarButtonItem = rightBar
        
        view.addSubview(textView)
        
        view.addSubview(secPanel)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        if let item = post{
            loadData(item.replylink!)
        }
        
    }
    
    func clicksecret(){
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func keyboardWillShow(notification : NSNotification){
        fd_interactivePopDisabled = true   //弹出键盘后,需要禁止滑动pop上一层
        textView.scrollEnabled = false //禁止内容滚动
        
        let userinfo = notification.userInfo
        let keyboardRect = userinfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardRect?.size.height
        
        secPanel.transform = CGAffineTransformMakeTranslation(0, -(keyboardHeight!))
    }
    
    func keyboardWillHide(notification : NSNotification){
        fd_interactivePopDisabled = false      //键盘落下后, 需要恢复全屏滑动功能
        textView.scrollEnabled = true
        secPanel.transform = CGAffineTransformIdentity
    }
    
    func loadData(link : String){
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.labelText = "加载中..."
        SJClient.sharedInstance.getReplyForm((post?.replylink)!) { [weak self] (finish, result, sec) in
            progressHUD.hide(true)
            if finish{
                self!.replyform = result
                self!.sec = sec
                if sec != nil{

                    SJClient.sharedInstance.downloadReplySeccodeImage2(self!.fid, tid: self!.tid, reppost: self!.replyform!.reppost!, src: sec!.secimage!, completed: { (imagefile) in
                        let imagefile = dp("secreply.png")
                        if let imagedata = NSData(contentsOfFile: imagefile) {
                            self!.secImageView.image = UIImage.init(data: imagedata)
                        }
                    })
                    self!.secPanel.hidden = false
                }else{
                    self!.secPanel.hidden = true
                }
            }else{
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "加载失败"
                progressHUD.completionBlock = {
                    self!.navigationController?.popViewControllerAnimated(true)
                }
                progressHUD.hide(true)
            }
        }
    }
    
    func sendReply(){
        
        let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.labelText = "回复中..."
        
        SJClient.sharedInstance.sendReply(text, replyform: replyform!, sec : self.sec, seccode : self.sectextfield.text, completed: { [weak self] (finish) in
            if !finish{
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.labelText = "回复失败"
            }else{
                self!.sectextfield.text = ""
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progressHUD.labelText = "回复成功"
                progressHUD.completionBlock = {
                    self!.navigationController?.popViewControllerAnimated(true)
                }
            }
            progressHUD.mode = .CustomView
            
            
            progressHUD.hide(true)
        })
    
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension SJReplyViewController : UITextViewDelegate{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if text.characters.count > 0 {
            reply.enabled = true
        }else{
            reply.enabled = false
        }
        
        return true
    }
}

extension SJReplyViewController : UITextFieldDelegate{
    
}
