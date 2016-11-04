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
    
    var post : SJPostModel?
    var replyform : SJReplyFormModel?
    
    private lazy var textView : KMPlaceholderTextView = { [unowned self] in
        let v = KMPlaceholderTextView(frame : CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds)))
        v.placeholder = "此刻我正在想对Ta说些什么..."
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        title = "回复 \(post?.author!)"
        
        let rightBar = UIBarButtonItem(customView: reply)
        navigationItem.rightBarButtonItem = rightBar
        
        view.addSubview(textView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        if let item = post{
            loadData(item.replylink!)
        }
        
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
    }
    
    func keyboardWillHide(notification : NSNotification){
        fd_interactivePopDisabled = false      //键盘落下后, 需要恢复全屏滑动功能
        textView.scrollEnabled = true
    }
    
    func loadData(link : String){
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.labelText = "加载中..."
        SJClient.sharedInstance.getReplyForm((post?.replylink)!) { [weak self] (finish, result) in
            progressHUD.hide(true)
            dprint(result)
            if finish{
                self!.replyform = result
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
        SJClient.sharedInstance.sendReply(text, replyform: replyform!, completed: { [weak self] (finish) in
            if !finish{
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.labelText = "回复失败"
            }else{
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
