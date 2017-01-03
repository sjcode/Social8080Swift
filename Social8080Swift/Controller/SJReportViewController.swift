//
//  SJReportViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/12/9.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import MBProgressHUD

class SJReportViewController: SJViewController {
    
    var items: [String] = [
        "广告贴子",
        "恶意灌水",
        "违规内容",
        "文不对题",
        "其他问题",
    ]
    
    private lazy var textView : KMPlaceholderTextView = { [unowned self] in
        let v = KMPlaceholderTextView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.grayColor().CGColor
        v.placeholder = "举报内容..."
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.font = defaultFont(14)
        v.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        v.textColor = UIColor.grayColor()
        v.keyboardDismissMode = .Interactive
        return v
        }()
    
    private lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let b = UIButton(type: .System)
        b.setTitle("提交", forState: .Normal)
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.titleLabel?.font = UIFont.systemFontOfSize(14)
        b.sizeToFit()
        b.addTarget(self, action: #selector(send(_:)), forControlEvents: .TouchUpInside)
        let right = UIBarButtonItem(customView: b)
        return right
    }()
    
    func send(sender: AnyObject) {
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
            progressHUD.mode = .CustomView
            progressHUD.labelText = "提交成功"
            progressHUD.completionBlock = { [weak self] in
                self!.navigationController?.popViewControllerAnimated(true)
            }
            progressHUD.hide(true, afterDelay: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "举报"
        
        navigationItem.rightBarButtonItem = rightButton
        addChecks()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        
        let constraints = [NSLayoutConstraint(item: textView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH - 20),
                           NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 80),
                           NSLayoutConstraint(item: textView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: view.viewWithTag(items.count-1), attribute: .Bottom, multiplier: 1, constant: 5),
        ]
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        view.addTapEventHandle { [weak self] (gesture) in
            self!.textView.resignFirstResponder()
        }
    }
    
    func createButton(title: String) -> UIButton {
        let b = UIButton(type: .Custom)
        b.setTitle(title, forState: .Normal)
        b.setTitleColor(UIColor.grayColor(), forState: .Normal)
        b.adjustsImageWhenHighlighted = false
        b.setImage(UIImage(named: "icon_uncheck"), forState: .Normal)
        b.setImage(UIImage(named: "icon_checked"), forState: .Selected)
        b.addTarget(self, action: #selector(check(_:)), forControlEvents: .TouchUpInside)
        return b
    }
    
    func check(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    func addChecks() {
        
        var offsetY: CGFloat = 8

        for (tag, item) in items.enumerate() {
            let b = createButton(item)
            b.tag = tag
            b.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(b)
            
            view.addConstraints([
                NSLayoutConstraint(item: b, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 120),
                NSLayoutConstraint(item: b, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 30),
                NSLayoutConstraint(item: b, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: b, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: offsetY),
            ])
            
            offsetY += 30 + 5
        }
        
        
    }
}
