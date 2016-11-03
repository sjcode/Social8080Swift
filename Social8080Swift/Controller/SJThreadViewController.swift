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
import MWPhotoBrowser
import SVWebViewController

class SJThreadViewController: SJViewController {
    var link : String?{
        didSet{
            tid = Int(extractByRegex(link!, pattern : "forum.php\\?mod=viewthread&tid=(\\d+)&mobile=yes"))
            if tid == nil{//如果不是从home过来的, 那就一定是从message过来的
                tid = Int(extractByRegex(link!, pattern : "forum.php\\?mod=redirect&goto=findpost&ptid=(\\d+)&pid="))
            }
        }
    }
    private var tid : Int?
    private var page : Int = 1
    private var dataArray = [SJPostModel]()
    private var lastArray = [SJPostModel]()
    
    private var selectedPost : Int?
    
    private lazy var maskDarkView : UIView = { [unowned self] in
        let v = UIView(frame: self.view.bounds)
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.backgroundColor = UIColor.init(white: 0.126, alpha: 0.5)
        v.addTapEventHandle { [weak self ](gesture) in
            self!.maskDarkView.removeFromSuperview()
            self!.textView.endEditing(true)
        }
        return v
    }()
    
    private lazy var popupViewController : SJPopUpViewControllerSwift = {[unowned self] in
        let vc = SJPopUpViewControllerSwift()
        
        vc.reply.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.popupViewController.hide()
            let vc = SJReplyViewController()
            vc.post = self!.dataArray[self!.selectedPost!] as SJPostModel
            self!.navigationController?.pushViewController(vc, animated: true)
        })
        vc.favour.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            dprint("selectedPost \(self!.selectedPost)")
        })
        vc.share.handleControlEvent(.TouchUpInside, closure: {  [weak self] in
            dprint("selectedPost \(self!.selectedPost)")
        })
        return vc
    }()
    
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 35 ), style: .Plain)
        v.backgroundColor = UIColor.groupTableViewBackgroundColor()
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
        label.text = "我想说些..."
        label.backgroundColor = UIColor.whiteColor()
        label.font = defaultFont(10)
        label.textColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        label.contentInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        v.addSubview(label)
        label.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(v)
            make.left.equalTo(8)
            make.right.equalTo(v).offset(-30)
            make.height.equalTo(28)
        })
        v.addTapEventHandle({ [weak self] (gesture) in
            self!.addMaskDarkView()
            self!.editPanel.hidden = true
            self!.panelTitle.text = "写跟帖"
            self!.selectedPost = -1
            self!.textView.becomeFirstResponder()
        })
        return v
    }()
    
    private lazy var panelTitle : UILabel = {
        let l = UILabel()
        l.text = "写跟贴"
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(16)
        return l
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
        
        v.addSubview(self.panelTitle)
        self.panelTitle.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(v)
            make.top.equalTo(6)
        })
        
        let cancel = UIButton(type: .System)
        cancel.setTitle("取消", forState: .Normal)
        cancel.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancel.titleLabel?.font = defaultFont(12)
        cancel.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.maskDarkView.removeFromSuperview()
            self!.textView.endEditing(true)
        })
        
        v.addSubview(cancel)
        cancel.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(8)
            make.top.equalTo(2)
            make.size.equalTo(CGSizeMake(50, 30))
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
        t.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
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
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    
    func addMaskDarkView(){
        view.insertSubview(maskDarkView, belowSubview: showPanel)
    }
    
    func loadData(link : String){
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "加载中..."
        SJClient.sharedInstance.getPostList(link, page: page) { [weak self](title, posts) in
            self!.title = title
            progressHud.hide(true)
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
                        self!.page = self!.page - 1
                        alertmessage(self!.view, message: "没有更多的数据了")
                    }
                }
            }
            self!.lastArray = posts
            self!.tableView .reloadData()
            self!.tableView.mj_header.endRefreshing()
            self!.tableView.mj_footer.endRefreshing()
        }
    }
    
    func clicksend(sender : UIButton){
        textView.endEditing(true)
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.labelText = "发送中..."
        
        //直接回贴
        SJClient.sharedInstance.sendPost(textView.text, tid: tid!) { [weak self] (finish) in
            progressHud.hide(true)
            if finish{
                self?.textView.text = ""
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "回贴成功"
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
    
    func clickimage(gesture : UITapGestureRecognizer){
        if let cell = gesture.view?.superview?.superview{
            if let indexPath = tableView.indexPathForCell(cell as! UITableViewCell){
                let point = gesture.locationInView(gesture.view)
                var imageView : UIImageView?
                for v in (gesture.view?.subviews)!{
                    if CGRectContainsPoint(v.frame, point){
                        imageView = v as? UIImageView
                        break
                    }
                }
                
                var index = 0
                if let v = imageView{
                    index = (gesture.view?.subviews.indexOf(v))!
                    dprint("index = \(index)")
                }
                
                var photos : [MWPhoto] = []
                for image in dataArray[indexPath.row].images!{
                    let photo = MWPhoto(URL: NSURL.init(string: image.originalurl!))
                    photos.append(photo)
                }
                
                let browser = MWPhotoBrowser(photos: photos)
                browser.displayActionButton = true
                browser.displayNavArrows = true;
                browser.displaySelectionButtons = false
                browser.alwaysShowControls = false
                browser.zoomPhotosToFill = true
                browser.enableGrid = false;
                browser.startOnGrid = false
                browser.enableSwipeToDismiss = false
                browser.autoPlayOnAppear = false
                browser.displaySelectionButtons = false
                browser.setCurrentPhotoIndex(UInt(index))
                
                navigationController?.pushViewController(browser, animated: true)
            }
        }
    }
    
    func keyboardWillShow(notification : NSNotification){
        fd_interactivePopDisabled = true   //弹出键盘后,需要禁止滑动pop上一层
        tableView.scrollEnabled = false //禁止内容滚动
        let userinfo = notification.userInfo
        let keyboardRect = userinfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardRect?.size.height
        
        showPanel.transform = CGAffineTransformMakeTranslation(0, -(110+keyboardHeight!+64))
        
        
        var heightOfVisibleCells : CGFloat = 0
        for cell in tableView.visibleCells{
            heightOfVisibleCells += cell.frame.size.height
        }
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
        cell.tapimage.addTarget(self, action: #selector(clickimage(_:)))
        
        cell.content.addTapEventHandle { [weak self] (gesture) in
            self!.selectedPost = gesture.view!.tag
            self!.popupViewController.showInView(self!.view)
        }
        cell.content.delegate = self
        cell.content.tag = indexPath.row
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
        
        selectedPost = indexPath.row
        popupViewController.showInView(view)
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

extension SJThreadViewController : UITextViewDelegate{
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
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        print(URL)
        let tid = extractByRegex(URL.absoluteString, pattern: "http://bbs.8080.net/thread-(\\d+)-\\d+-\\d+.html")
        if !tid.isEmpty{
            let vc = SJThreadViewController()
            vc.link = "forum.php?mod=viewthread&tid=" + tid + "&mobile=yes"
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let tid = extractByRegex(URL.absoluteString, pattern: "http://bbs.8080.net/forum.php\\?mod=viewthread&tid=(\\d+)")
            if !tid.isEmpty{
                let vc = SJThreadViewController()
                vc.link = "forum.php?mod=viewthread&tid=" + tid + "&mobile=yes"
                navigationController?.pushViewController(vc, animated: true)
            }else{
                let webViewController = SVModalWebViewController(URL: URL)
                webViewController.barsTintColor = UIColor.whiteColor()
                presentViewController(webViewController, animated: true, completion: nil)
            }
        }
        return false
    }
}

