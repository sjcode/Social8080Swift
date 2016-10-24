//
//  SJThreadViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import IQKeyboardManagerSwift
import FDFullscreenPopGesture
import MBProgressHUD

class SJThreadViewController: SJViewController {
    var fid : Int?
    var link : String?{
        didSet{
            tid = Int(extractByRegex(link!, pattern : "forum.php\\?mod=viewthread&tid=(\\d+)&mobile=yes"))
        }
    }
    var tid : Int?
    var page : Int = 1
    var dataArray = [SJPostModel]()
    var lastArray = [SJPostModel]()
    
    var popupView = SJPopUpViewControllerSwift()
    
    private lazy var tableView : UITableView = {
        let tableHeight = ScreenSize.SCREEN_HEIGHT
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 35 ), style: .Plain)
        let header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadData(self.link!)
        })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.page = self.page+1
            self.loadData(self.link!)
        })
        v.mj_header = header
        v.mj_footer = footer
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        v.separatorInset = UIEdgeInsetsZero
        v.delegate = self
        v.dataSource = self
        v.tableFooterView = UIView()

        v.registerClass(SJThreadTableViewCell.self, forCellReuseIdentifier: "SJThreadTableViewCell")
        return v
    }()
    
    private lazy var editPanel : UIView  = {
        let v = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        let divide = UIView()
        divide.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        divide.frame = CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        let label = SJMarginLabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        label.layer.borderWidth = 0.5
        label.text = "我想说些"
        label.userInteractionEnabled = true
        label.backgroundColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        label.contentInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        v.addSubview(label)
        label.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(v)
            make.left.equalTo(8)
            make.right.equalTo(v).offset(-30)
            make.height.equalTo(28)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickPanel(_:)))
        label.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var showPanel : UIView = { [unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        v.frame = CGRectMake(0, ScreenSize.SCREEN_HEIGHT, ScreenSize.SCREEN_WIDTH, 110)
        let divide = UIView()
        divide.backgroundColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        divide.frame = CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        v.addSubview(self.textView)
        self.textView.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(10)
            make.top.equalTo(v).offset(30)
            make.right.equalTo(v).offset(-10)
            make.bottom.equalTo(v).offset(-10)
        })
        
        let title = UILabel()
        title.text = "写跟贴"
        title.textColor = UIColor.grayColor()
        title.font = UIFont.systemFontOfSize(16)
        title.sizeToFit()
        v.addSubview(title)
        title.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(v)
            make.top.equalTo(6)
        })
        
        let cancel = UIButton(type: .System)
        cancel.setTitle("取消", forState: .Normal)
        cancel.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancel.titleLabel?.font = UIFont.systemFontOfSize(12)
        cancel.addTarget(self, action: #selector(clickcancel(_:)), forControlEvents: .TouchUpInside)
        v.addSubview(cancel)
        cancel.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(8)
            make.top.equalTo(2)
            make.size.equalTo(CGSizeMake(50, 30))
        })
        
        let send = UIButton(type: .System)
        send.setTitle("发送", forState: .Normal)
        send.setTitleColor(UIColor.grayColor(), forState: .Normal)
        send.titleLabel?.font = UIFont.systemFontOfSize(12)
        send.addTarget(self, action: #selector(clicksend(_:)), forControlEvents: .TouchUpInside)
        v.addSubview(send)
        send.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-8)
            make.top.equalTo(2)
            make.size.equalTo(CGSizeMake(50, 30))
        })
        return v
    }()
    
    private lazy var textView : UITextView = {
        let t = UITextView()
        t.backgroundColor = UIColor.whiteColor()
        t.showsVerticalScrollIndicator = false
        t.showsHorizontalScrollIndicator = false
        t.pagingEnabled = false
        t.delegate = self
        t.textColor = UIColor.grayColor()
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        t.layer.borderWidth = 0.5
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //动画隐藏tarbar
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.tabBarController?.tabBar.transform = CGAffineTransformMakeTranslation(0, 49)
        }
        
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //动画显示tabbar
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.tabBarController?.tabBar.transform = CGAffineTransformIdentity
        }
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func loadData(link : String){
        SJClient.sharedInstance.getPostList(link, page: page) { [weak self](posts) in
            if self!.page == 1{
                self!.dataArray = posts
            }else{
                if self!.lastArray.count != posts.count{
                    self!.dataArray.appendContentsOf(posts)
                }else{
                    let b = self!.lastArray.elementsEqual(posts, isEquivalent: { (src, dest) -> Bool in
                        let b = src.postid == dest.postid
                        return b
                    })
                    if !b {
                        self!.dataArray.appendContentsOf(posts)
                    }else{
                        dprint("没有更多的数据了")
                    }
                }
            }
            self!.lastArray = posts
            self!.tableView .reloadData()
            self!.tableView.mj_header.endRefreshing()
            self!.tableView.mj_footer.endRefreshing()
        }
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        textView.endEditing(true)
//    }
    
    func clickcancel(sender : UIButton){
        textView.endEditing(true)
    }
    
    func clicksend(sender : UIButton){
        textView.endEditing(true)
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.label.text = "发送中..."
        
        SJClient.sharedInstance.sendPost(textView.text, fid : fid!, tid: tid!) { [weak self] in
            progressHud.hideAnimated(true, afterDelay: 1)
            self?.textView.text = ""
            self!.tableView.mj_header.beginRefreshing()
        }
    }
    
    func clickPanel(tap : UITapGestureRecognizer){
        dprint("弹出编辑框")
        editPanel.hidden = true
        textView.becomeFirstResponder()
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
}

extension SJThreadViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJThreadTableViewCell", forIndexPath: indexPath) as! SJThreadTableViewCell
        let item = dataArray[indexPath.row]
        cell.configCell(item)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = SJThreadTableViewCell.calculateCellHeight(dataArray[indexPath.row])

        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textView.resignFirstResponder()
        //popupView.showInView(view)
    }
}

extension SJThreadViewController : UITextViewDelegate{
    func textViewDidEndEditing(textView: UITextView) {
        dprint("textViewDidEndEditing")
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        dprint("textViewShouldEndEditing")
        return true
    }
}
