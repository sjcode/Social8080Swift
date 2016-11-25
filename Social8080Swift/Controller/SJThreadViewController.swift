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
import FLAnimatedImage
import MagicalRecord

class SJThreadViewController: SJViewController {
    var threadModel : SJThreadModel!
    var fid : Int!
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
    private var sec : SJSecCodeModel?
    private var selectedPost : Int?
    
    private lazy var maskDarkView : UIView = { [unowned self] in
        let v = UIView(frame: self.view.bounds)
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.backgroundColor = UIColor.init(white: 0.126, alpha: 0.5)
        v.addTapEventHandle { [weak self ](gesture) in
            self!.maskDarkView.removeFromSuperview()
            self!.view.endEditing(true)
        }
        return v
    }()
    
    private lazy var popupViewController : SJPopUpViewControllerSwift = {[unowned self] in
        let vc = SJPopUpViewControllerSwift()
        
        vc.reply.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.popupViewController.hide()
            let vc = SJReplyViewController()
            vc.fid = self!.fid
            vc.tid = self!.tid
            
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
        let v = UITableView(frame: CGRectZero, style: .Plain)
        v.backgroundColor = UIColor.groupTableViewBackgroundColor()
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.loadData(self!.threadModel.tid!)
        })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.page = self!.page+1
            self!.loadData(self!.threadModel.tid!)
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
        divide.frame = ccr(0, 0, ScreenSize.SCREEN_WIDTH, 0.5)
        v.addSubview(divide)
        
        let label = SJMarginLabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
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
            make.right.equalTo(v).offset(-8)
            make.height.equalTo(28)
        })
        v.addTapEventHandle({ [weak self] (gesture) in
            self!.addMaskDarkView()
            self!.editPanel.hidden = true
            self!.panelTitle.text = "写跟帖"
            self!.selectedPost = -1
            if self!.sec != nil{
                self!.textView.snp_updateConstraints { (make) in
                    make.height.equalTo(45)
                }
            }
            
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
    
    private lazy var sendBtn : UIButton = {
        let b = UIButton(type: .System)
        b.setTitle("发送", forState: .Normal)
        b.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        b.setTitleColor(UIColor ( red: 0.1938, green: 0.5085, blue: 0.8523, alpha: 1.0 ), forState: .Normal)
        b.titleLabel?.font = defaultFont(12)
        b.enabled = false
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.view.endEditing(true)
            self!.maskDarkView.removeFromSuperview()
            let progressHud = MBProgressHUD.showHUDAddedTo((self!.navigationController?.view)!, animated: true)
            progressHud.labelText = "发送中..."
            
            //直接回贴
            SJClient.sharedInstance.sendPost(self!.textView.text, tid: self!.tid!, sec : self!.sec, seccode: self!.sectextfield.text) { [weak self] (finish) in
                progressHud.hide(true)
                if finish{
                    self!.textView.text = ""
                    self!.sectextfield.text = ""
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
        })
        return b
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
            make.height.equalTo(70)
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
            self!.view.endEditing(true)
        })
        
        v.addSubview(cancel)
        cancel.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(8)
            make.top.equalTo(2)
            make.size.equalTo(ccs(50, 30))
        })
        
        v.addSubview(self.sendBtn)
        self.sendBtn.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-8)
            make.top.equalTo(2)
            make.size.equalTo(ccs(50, 30))
        })
        
        v.addSubview(self.secImageView)
        self.secImageView.snp_makeConstraints(closure : { [weak self] (make) in
            make.size.equalTo(ccs(80, 30))
            make.left.equalTo(self!.textView)
            make.top.equalTo(self!.textView.snp_bottom).offset(3)
        })
        
        v.addSubview(self.sectextfield)
        self.sectextfield.snp_makeConstraints(closure : { [weak self] (make) in
            make.size.equalTo(ccs(80, 30))
            make.left.equalTo(self!.secImageView.snp_right).offset(3)
            make.top.equalTo(self!.textView.snp_bottom).offset(3)
        })
        return v
    }()
    
    private lazy var textView : UITextView = {
        let t = UITextView()
        t.backgroundColor = UIColor.whiteColor()
        t.showsVerticalScrollIndicator = false
        t.showsHorizontalScrollIndicator = false
        t.pagingEnabled = false
        t.keyboardAppearance = .Dark
        t.delegate = self
        t.textColor = UIColor.grayColor()
        t.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        t.layer.borderWidth = 0.5
        return t
    }()
    
    private lazy var secImageView : UIImageView = {
        let v = UIImageView(image: UIImage.init(named: "loadingImage_50x118"))
        v.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clicksecret))
        v.addGestureRecognizer(tap)
        v.hidden = true
        return v
    }()
    
    private lazy var sectextfield : UITextField = {
        let t = UITextField()
        t.placeholder = "请输入验证码"
        t.font = defaultFont(12)
        t.backgroundColor = UIColor.whiteColor()
        t.autocorrectionType = .No
        t.keyboardType = .ASCIICapable
        t.keyboardAppearance = .Dark
        t.autocapitalizationType = .None
        t.delegate = self
        t.textColor = UIColor.grayColor()
        t.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.layer.borderColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 ).CGColor
        t.layer.borderWidth = 0.5
        t.hidden = true
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp_makeConstraints { [weak self] (make) in
            make.edges.equalTo(self!.view)
            if SJClient.sharedInstance.user != nil{
                make.height.equalTo(ScreenSize.SCREEN_HEIGHT - 35)
            }
        }
        
        view.addSubview(showPanel)
        
        if SJClient.sharedInstance.user != nil {
            view.addSubview(editPanel)
            editPanel.snp_makeConstraints { [weak self] (make) in
                make.height.equalTo(35)
                make.left.equalTo(0)
                make.right.equalTo(self!.view)
                make.bottom.equalTo(self!.view)
            }
        }
        
        shyNavBarManager.scrollView = tableView
        
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
    
    func loadData(tid : String){
        SJClient.sharedInstance.getPostList(tid, page: page) { [weak self](title, posts, sec) in
            if let t = title{
                self!.title = t
            }
            self!.sec = sec
            if let s = self!.sec{
                SJClient.sharedInstance.downloadReplySeccodeImage(self!.tid!, src: s.secimage!, completed: { (imagefile) in
                    let imagefile = dp("secreply.png")
                    if let imagedata = NSData(contentsOfFile: imagefile) {
                        self!.secImageView.image = UIImage.init(data: imagedata)
                    }
                })
                self!.secImageView.hidden = false
                self!.sectextfield.hidden = false
            }else{
                self!.secImageView.hidden = true
                self!.sectextfield.hidden = true
            }
            if self!.page == 1{
                self!.dataArray = posts
            }else{
                if self!.lastArray.count != posts.count{
                    self!.dataArray.appendContentsOf(posts)
                }else{
                    let b = self!.lastArray.elementsEqual(posts, isEquivalent: { (src, dest) -> Bool in
                        //let b = src.postid == dest.postid
                        let b = src.floor == dest.floor
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

    func clicksecret(){
    
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
        
        showPanel.transform = CGAffineTransformMakeTranslation(0, -(110+keyboardHeight!))
        
        
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
    
    func updateSendButtonState(){
        if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0{
            
            if sec != nil{
                if sectextfield.text?.characters.count > 0{
                    sendBtn.enabled = true
                }else{
                    sendBtn.enabled = false
                }
            }else{
                sendBtn.enabled = true
            }
        }else{
            sendBtn.enabled = false
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
        
        if SJClient.sharedInstance.user != nil{
            selectedPost = indexPath.row
            popupViewController.showInView(view)
        }
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

extension SJThreadViewController : UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        updateSendButtonState()
        return true
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
    
    func textViewDidChange(textView: UITextView){
        updateSendButtonState()
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

//extension SJThreadViewController{
//    func storeRecentRead() {
//        let predicate = NSPredicate(format: "tid == %@", String(tid!))
//        let count = RecentReadThread.MR_countOfEntitiesWithPredicate(predicate)
//        if count == 0{
//            if let r = RecentReadThread.MR_createEntity(){
//                r.tid = String(tid!)
//                r.uid = threadModel.uid
//                r.title = threadModel.title
//                r.author = threadModel.author
//                r.datetime = threadModel.datetime?.stringFromDate
//                r.link = threadModel.link
//                
//                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//            }
//        }
//    }
//}

