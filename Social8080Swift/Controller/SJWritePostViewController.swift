//
//  SJWritePostViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/1.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KMPlaceholderTextView
import MBProgressHUD

class SJWritePostViewController: SJViewController {
    //MARK: Public Property
    var fid : Int?
    var menus : [NSDictionary]?
    var model : SJNewThreadFormModel?
    //MARK: Private Property
    private lazy var suject : SJTextField = { [unowned self] in
        let f = SJTextField(frame: CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        f.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]  //左右上两边紧贴父视图, 下部为可边距.
        f.borderStyle = .None
        f.font = defaultFont(14)
        f.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        let attributedString = NSMutableAttributedString.init(string: "标题", attributes: [NSFontAttributeName : defaultFont(12), NSForegroundColorAttributeName : UIColor ( red: 0.5178, green: 0.5816, blue: 0.5862, alpha: 1.0 )])
        f.attributedPlaceholder = attributedString
        f.textColor = UIColor.grayColor()
        f.rightView = self.clear
        f.rightViewMode = .WhileEditing
        return f
    }()
    
    private lazy var clear : UIButton = { [unowned self] in
        let b = UIButton(type: .Custom)
        b.setImage(UIImage.init(named: "Clear"), forState: .Normal)
        b.sizeToFit()
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.suject.text = ""
        })
        return b
    }()
    
    private lazy var textView : KMPlaceholderTextView = { [unowned self] in
        let v = KMPlaceholderTextView(frame : CGRectMake(0, 32, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds) - 30))
        v.placeholder = "此刻我正在想些什么..."
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.font = defaultFont(14)
        v.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        v.textColor = UIColor.grayColor()
        return v
    }()
    
    private lazy var divideline : UIView = {
        let v = UIView(frame : CGRectMake(0, 30, ScreenSize.SCREEN_WIDTH, 0.5))
        v.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        v.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        return v
    }()
    
    private lazy var reply : UIButton = {
        let b = UIButton(type: .System)
        b.setTitle("发贴", forState: .Normal)
        b.sizeToFit()
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.enabled = false
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.view.endEditing(true)
            self!.categoryViewController.showInView(self!.view)
        })
        return b
    }()
    
    private lazy var categoryViewController : SJChooseCategoryViewController = {
        let vc = SJChooseCategoryViewController()
        vc.datasource = self
        vc.delegate = self
        return vc
    }()
    
    //MARK: View Appearance
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发贴"
        view.backgroundColor = UIColor.whiteColor()
        let rightBar = UIBarButtonItem(customView: reply)
        navigationItem.rightBarButtonItem = rightBar
        
        view.addSubview(suject)
        view.addSubview(divideline)
        view.addSubview(textView)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        loadForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.tabBarController?.tabBar.transform = CGAffineTransformMakeTranslation(0, 49)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let viewControllers = (navigationController?.viewControllers)! as NSArray
        if viewControllers.count > 1 && viewControllers[viewControllers.count - 2] as! NSObject == self{
        }else if (viewControllers.indexOfObject(self)) == NSNotFound{
            UIView.animateWithDuration(0.25) { [weak self] in
                self!.tabBarController?.tabBar.transform = CGAffineTransformIdentity
            }
        }
    }
    
    func keyboardWillShow(notification : NSNotification){
        fd_interactivePopDisabled = true   //弹出键盘后,需要禁止滑动pop上一层
        let userinfo = notification.userInfo
        let keyboardRect = userinfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardRect?.size.height
        
        var textViewframe = textView.frame
        
        
        let newHeight = textViewframe.size.height - keyboardHeight!
        if newHeight < view.bounds.size.height - 30{
            return
        }
        
        textViewframe.size.height = newHeight
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.textView.frame = textViewframe
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        fd_interactivePopDisabled = false      //键盘落下后, 需要恢复全屏滑动功能
        var textViewframe = textView.frame
        let newHeight = view.bounds.size.height - 30
        textViewframe.size.height = newHeight
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.textView.frame = textViewframe
        }
    }
    
    func loadForm(){
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.labelText = "加载中..."
        SJClient.sharedInstance.getNewThreadForm(fid!){ [weak self] (finish, result) in
            progressHUD.hide(true)
            if finish{
                self!.model = result
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
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension SJWritePostViewController : SJChooseCategoryDataSource, SJChooseCategoryDelegate{
    func numberOfMenus(vc : SJChooseCategoryViewController) -> Int {
        return model!.category.count
    }
    
    func titleAtIndex(vc : SJChooseCategoryViewController, index : Int) -> String {
        return model!.category[index].name!
    }
    
    func didSelectedIndexOfTitle(vc : SJChooseCategoryViewController, index : Int){
        dprint("select \(model?.category[index].name)")
        categoryViewController.hide()
        
        let progresshud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progresshud.labelText = "提交中..."
        
        SJClient.sharedInstance.sendNewThread(suject.text!, content: textView.text, category: (model?.category[index].value)!, model: model!) { [weak self] (finish) in
            if !finish{
                progresshud.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progresshud.labelText = "发贴失败"
            }else{
                progresshud.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progresshud.labelText = "发贴成功"
                progresshud.completionBlock = {
                    self!.navigationController?.popViewControllerAnimated(true)
                }
            }
            progresshud.mode = .CustomView
            progresshud.hide(true)
        }
        
        progresshud.hide(true, afterDelay: 1)
        
    }
}
