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
class SJWritePostViewController: SJViewController {
    //MARK: Public Property
    var fid : Int?
    
    //MARK: Private Property
    private lazy var suject : SJTextField = { [unowned self] in
        let f = SJTextField(frame: CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        f.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]  //左右上两边紧贴父视图, 下部为可边距.
        f.borderStyle = .None
        f.font = defaultFont(14)
        f.tintColor = UIColor ( red: 0.5178, green: 0.5816, blue: 0.5862, alpha: 1.0 )
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
        b.addTarget(self, action: #selector(clickclear(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var textView : KMPlaceholderTextView = { [unowned self] in
        let v = KMPlaceholderTextView(frame : CGRectMake(0, 30, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds) - 30))
        v.placeholder = "此刻我正在想些什么..."
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.font = defaultFont(14)
        v.textColor = UIColor.grayColor()
        return v
    }()
    
    //MARK: View Appearance
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发贴"
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(suject)
//        suject.snp_makeConstraints { [weak self] (make) in
//            make.top.equalTo(self!.view)
//            make.left.equalTo(self!.view)
//            make.right.equalTo(self!.view)
//            make.height.equalTo(30)
//        }
        view.addSubview(textView)
//        textView.snp_makeConstraints { [weak self] (make) in
//            make.left.equalTo(self!.view)
//            make.top.equalTo(self!.suject.snp_bottom)
//            make.right.equalTo(self!.view)
//            make.bottom.equalTo(self!.view)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.tabBarController?.tabBar.transform = CGAffineTransformMakeTranslation(0, 49)
        }
        IQKeyboardManager.sharedManager().enable = false
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
        IQKeyboardManager.sharedManager().enable = true
    }
    
    //MARK: Action
    func clickclear(sender : UIButton) {
        
    }
}
