//
//  SJMessageDetailViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/28.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD
import IQKeyboardManagerSwift

class SJMessageDetailViewController: SJViewController {
    //MARK: Pirvate Property
    var model : SJMessageModel?
    private var messageArray = [SJMessageModel]()
    private var reply : SJReplyModel?
    private lazy var tableView : UITableView = { [unowned self] in
        let v = UITableView(frame: self.view.bounds, style: .Grouped)
        v.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        v.separatorInset = UIEdgeInsetsZero
        v.dataSource = self
        v.delegate = self
        v.registerClass(SJMessageDetailTableViewCell.self, forCellReuseIdentifier: "SJMessageDetailTableViewCell")
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
                self!.loadData()
            })
        
        v.mj_header = header
        return v
    }()
    
    private lazy var editPanel : UIView  = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        let divide = UIView()
        divide.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        divide.frame = ccr(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        let label = SJMarginLabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        label.layer.borderWidth = 0.5
        label.text = "我想对" + getNickname(self.model!.talk!) + "说..."
        label.userInteractionEnabled = true
        label.backgroundColor = UIColor.whiteColor()
        label.font = defaultFont(10)
        label.textColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        label.contentInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        v.addSubview(label)
        label.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(v)
            make.left.equalTo(8)
            make.right.equalTo(v).offset(-8)
            make.height.equalTo(28)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickPanel(_:)))
        label.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var showPanel : UIView = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        v.frame = ccr(0, ScreenSize.SCREEN_HEIGHT, ScreenSize.SCREEN_WIDTH, 110)
        let divide = UIView()
        divide.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        divide.frame = ccr(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        v.addSubview(self.textView)
        self.textView.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(10)
            make.top.equalTo(v).offset(30)
            make.right.equalTo(v).offset(-10)
            make.bottom.equalTo(v).offset(-10)
        })
        
        let title = UILabel()
        title.text = "发消息"
        title.textColor = UIColor.grayColor()
        title.font = defaultFont(16)
        title.sizeToFit()
        v.addSubview(title)
        title.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(v)
            make.top.equalTo(6)
        })
        
        let cancel = UIButton(type: .System)
        cancel.setTitle("取消", forState: .Normal)
        cancel.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancel.titleLabel?.font = defaultFont(12)
        cancel.addTarget(self, action: #selector(clickcancel(_:)), forControlEvents: .TouchUpInside)
        v.addSubview(cancel)
        cancel.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(8)
            make.top.equalTo(2)
            make.size.equalTo(ccs(50, 30))
        })
        
        let send = UIButton(type: .System)
        send.setTitle("发送", forState: .Normal)
        send.setTitleColor(UIColor.grayColor(), forState: .Normal)
        send.titleLabel?.font = defaultFont(12)
        send.addTarget(self, action: #selector(clicksend(_:)), forControlEvents: .TouchUpInside)
        v.addSubview(send)
        send.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-8)
            make.top.equalTo(2)
            make.size.equalTo(ccs(50, 30))
        })
        return v
        }()
    
    private lazy var textView : UITextView = {
        let t = UITextView()
        t.delegate = self
        t.backgroundColor = UIColor.whiteColor()
        t.showsVerticalScrollIndicator = false
        t.showsHorizontalScrollIndicator = false
        t.pagingEnabled = false
        t.textColor = UIColor.grayColor()
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        t.layer.borderWidth = 0.5
        return t
    }()
    //MARK: View Life
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "会话"
        view.addSubview(tableView)
        view.addSubview(editPanel)
        view.addSubview(showPanel)
        editPanel.snp_makeConstraints { [weak self] (make) in
            make.height.equalTo(35)
            make.left.equalTo(0)
            make.right.equalTo(self!.view)
            make.bottom.equalTo(self!.view)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        tableView.mj_header.beginRefreshing()
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    //MARK: Appearance
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    //MARK: Action
    func clickPanel(tap : UITapGestureRecognizer){
        textView.becomeFirstResponder()
    }
    
    func clickcancel(sender : UIButton){
        textView.endEditing(true)
    }
    
    func clicksend(sender : UIButton){
        textView.endEditing(true)
        
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.labelText = "发送中..."
        
        SJClient.sharedInstance.sendMessage(reply!, message: textView.text) { [weak self] (finish) in
            progressHud.hide(true)
            if finish{
                self!.textView.text = ""
                
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "发送成功"
                progressHUD.completionBlock = { [weak self] in
                    self!.tableView.mj_header.beginRefreshing()
                }
                progressHUD.hide(true, afterDelay: 1)
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        }
    }
    
    func keyboardWillShow(notification : NSNotification){
        fd_interactivePopDisabled = true   //弹出键盘后,需要禁止滑动pop上一层
        tableView.scrollEnabled = false //禁止内容滚动
        let userinfo = notification.userInfo
        let keyboardRect = userinfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardRect?.size.height
        
        showPanel.transform = CGAffineTransformMakeTranslation(0, -(110+keyboardHeight!))
        
        
        var heightOfVisibleCells : CGFloat = 0
        for cell in tableView.visibleCells{
            heightOfVisibleCells += cell.frame.size.height
        }
        dprint("heightOfVisibleCells = \(heightOfVisibleCells)")
        if (heightOfVisibleCells + 110 + keyboardHeight!) > ScreenSize.SCREEN_HEIGHT{
            var tableframe = tableView.frame
            tableframe.origin.y = 0
            tableframe.origin.y -= ((110 - 40) + keyboardHeight!)
            UIView.animateWithDuration(0.25) { [weak self] in
                self!.tableView.frame = tableframe
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        fd_interactivePopDisabled = false      //键盘落下后, 需要恢复全屏滑动功能
        tableView.scrollEnabled = true
        showPanel.transform = CGAffineTransformIdentity
        editPanel.hidden = false
        var tableframe = tableView.frame
        tableframe.origin.y = 0
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.tableView.frame = tableframe
        }
    }
    //MARK: Data Handle
    func loadData(){
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.labelText = "加载中..."
        SJClient.sharedInstance.getMessageDetail((model?.link)!) { [weak self](finish, messages, reply) in
            progressHud.hide(true)
            self!.tableView.mj_header.endRefreshing()
            if finish{
                self!.reply = reply as? SJReplyModel
                self!.messageArray = messages
                self!.tableView.reloadData()
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        }
    }
}

extension SJMessageDetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJMessageDetailTableViewCell", forIndexPath: indexPath) as! SJMessageDetailTableViewCell
        cell.configCell(messageArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SJMessageDetailTableViewCell.calculateCellHeight(messageArray[indexPath.row])
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
}

extension SJMessageDetailViewController : UITextViewDelegate{
    //MARK: UITextViewDelegate
    func textViewDidEndEditing(textView: UITextView) {
        dprint("textViewDidEndEditing")
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        dprint("textViewShouldEndEditing")
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.isFirstResponder() {
            if textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji" {
                return false;
            }
        }
        return true;
    }
}


//MARK: Helper method

func getNickname(talk : String) -> String{
    if let range = talk.rangeOfString("我对"){
        let startindex = range.endIndex
        let endindex = talk.endIndex.advancedBy(-1)
        
        return talk[startindex..<endindex]
    }
    
    if let range = talk.rangeOfString("对我说"){
        let startindex = talk.startIndex
        let endindex = range.startIndex
        return talk[startindex..<endindex]
    }
    
    return ""
}
