//
//  SJHomeViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import Kanna
import MBProgressHUD
import Kingfisher
import MMDrawerController
import TLYShyNavBar
class SJHomeViewController: UIViewController {
    
    var forumPanelManager = SJForumPanelManager()
    var dataArray = [SJThreadModel]()
    var page : Int = 1
    var currentfid : Int = 85{
        didSet{
            loadMenus(currentfid)
            menuBar.reloadMenus()
            tableView_root.mj_header.beginRefreshing()
        }
    }
    var forumTable : NSArray?
    var currenttypeid : Int = -1
    private var menus = [NSDictionary]()
    
    private lazy var menuBar : SJScrollTitleView = {
        let menubar = SJScrollTitleView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        menubar.delegate = self
        menubar.datasource = self
        return menubar
    }()
    
    private lazy var tableView_root : UITableView = {
        let v = UITableView(frame: ccr(0, 0 , ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT ), style: .Plain)
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.page = 1
            self!.loadData(self!.currentfid, typeid: -1)
        })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.page = self!.page+1
            self!.loadData(self!.currentfid,typeid: self!.currenttypeid)
        })
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        v.mj_header = header
        v.mj_footer = footer
        v.tableFooterView = UIView()
        v.separatorInset = UIEdgeInsetsZero
        v.rowHeight = 62
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJHomeTableViewCell.self, forCellReuseIdentifier: "SJHomeTableViewCell")
        return v
    }()
    
    private lazy var rightbutton : UIButton = {
        let b = UIButton(type: .Custom)
        b.frame = ccr(0,0,48,48)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        b.setImage(UIImage.init(named: "person_normal"), forState: .Normal)
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            let vc = SJProfileViewController()
            self!.navigationController?.pushViewController(vc, animated: true)
        })
        return b
    }()
    
    private var isOpenPanel = false
    
    private lazy var leftbutton : UIButton = {
        let b = UIButton(type: .Custom)
        b.frame = ccr(0,0,48,48)
        b.setImage(UIImage.init(named: "icon_home_left") , forState: .Normal)
        b.clipsToBounds = true
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            //self!.mm_drawerController.toggleDrawerSide(.Left, animated : true,completion: nil)
            
            if self!.isOpenPanel{
                self!.darkMaskView.hidden = true
                self!.forumPanelManager.showPanel(false){
                    self!.isOpenPanel = false
                }
            }else{
                self!.darkMaskView.hidden = false
                self!.forumPanelManager.showPanel(true){ [weak self] in
                    self!.isOpenPanel = true
                }
            }
        })
        return b
    }()
    
    private lazy var darkMaskView : UIView = { [unowned self] in
        let v = UIView(frame: self.view.bounds)
        v.backgroundColor = UIColor ( red: 0.1264, green: 0.1264, blue: 0.1264, alpha: 0.5 )
        v.hidden = true
        
        v.addTapEventHandle { [weak self] (gesture) in
            v.hidden = true
            self!.forumPanelManager.showPanel(false){
                self!.isOpenPanel = false
            }
        }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        title = "极速社区"
        let fixedspace = UIBarButtonItem.init(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedspace.width = -38
        let items = [fixedspace,  UIBarButtonItem(customView: leftbutton)]
        navigationItem.leftBarButtonItems = items
        fixedspace.width += 20
        let itmes2 = [fixedspace, UIBarButtonItem(customView: rightbutton)]
        navigationItem.rightBarButtonItems = itmes2
        
        forumPanelManager.setupPanelAtContainer(navigationController!.view) { [weak self] (fid) in
            dprint("click forum item")
            self!.darkMaskView.hidden = true
            self!.isOpenPanel = false
            
            
            self!.currentfid = fid
            
        }
        
        
        view.addSubview(menuBar)
        view.addSubview(tableView_root)
        
        view.addSubview(darkMaskView)
        
        
        shyNavBarManager.scrollView = tableView_root
        
        if let fid = NSUserDefaults.standardUserDefaults().valueForKey("currentfid"){
            currentfid = Int(fid as! String)!
        }else{
            currentfid = 85
        }
        
        SJClient.sharedInstance.tryLoginAndLoadUI(false) { [weak self] (finish, error, user) in
            if finish{
                if let u = user{
                    
                    KingfisherManager.sharedManager.downloader.downloadImageWithURL(NSURL.init(string: u.middleavatarurl)!, options: [.ForceRefresh], progressBlock: nil, completionHandler: { [weak self](image, error, imageURL, originalData) in
                        if (image != nil){
                            self!.rightbutton.setImage(maskRoundedImage(image!.resizedImageWithBounds(ccs(30, 30)), radius: 15), forState: .Normal)
                        }
                    })
                }
            }
            
            self!.tableView_root.mj_header.beginRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //mm_drawerController.openDrawerGestureModeMask = .All  //此页支持左滑打开侧滑页
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        darkMaskView.hidden = true
        forumPanelManager.showPanel(false, complete: {})
        isOpenPanel = false
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    
    
    
    func loadData(fid : Int, typeid : Int){
        SJClient.sharedInstance.getThreadList(fid, typeid : typeid , page: page) { [weak self] (finish, threads) in
            if finish{
                if self!.page == 1{
                    self!.dataArray = threads
                }else{
                    self!.dataArray.appendContentsOf(threads)
                }
                
                self!.tableView_root.reloadData()
                self!.tableView_root.mj_header.endRefreshing()
                self!.tableView_root.mj_footer.endRefreshing()
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        }
    }
    
    func updateLoginState(user: SJUserModel?){
        if let u = user {
            rightbutton.kf_setImageWithURL(NSURL.init(string: u.middleavatarurl), forState: .Normal)
        }else{
            rightbutton.setImage(UIImage(named:"person_normal"), forState: .Normal)
        }
    }
    
    func loadMenus(fid : Int){
        if let path = NSBundle.mainBundle().pathForResource("forumtable", ofType: "plist"){
            if let entireArray = NSArray(contentsOfFile: path){
                forumTable = entireArray
                for section in entireArray {
                    let sectionArray = section["array"] as! NSArray
                    for forum in sectionArray {
                        if forum["fid"] as! String == String(fid){
                            let category = forum["array"] as! NSArray
                            menus = category as! [NSDictionary]
                            
                            let total = Dictionary(dictionaryLiteral: ("name", "全部"), ("typeid", "-1")) as NSDictionary
                            menus.insert(total, atIndex: 0)
                            break
                        }
                    }
                }
            }
        }
    }
    
    private lazy var defaultCell : UITableViewCell = {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "SJForumTableViewCell")
        cell.backgroundColor = UIColor.redColor()
        return cell
    }()
    
    func isUnread(thread : SJThreadModel) -> Bool{
        if let tid = Int(extractByRegex(thread.link!, pattern : "forum.php\\?mod=viewthread&tid=(\\d+)&mobile=yes")){
            let predicate = NSPredicate(format: "tid == %@", String(tid))
            let count = RecentReadThread.MR_countOfEntitiesWithPredicate(predicate)
            
            
            return count == 0 ? true : false
        }
        
        return true
    }
}

extension SJHomeViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJHomeTableViewCell", forIndexPath: indexPath) as! SJHomeTableViewCell
        let thread = dataArray[indexPath.row]
        cell.configCell(thread)
        if isUnread(thread){
            cell.title.textColor = UIColor ( red: 0.1118, green: 0.1118, blue: 0.1118, alpha: 1.0 )
        }else{
            cell.title.textColor = UIColor ( red: 0.5178, green: 0.5816, blue: 0.5862, alpha: 1.0 )
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == tableView_root {
            let item = dataArray[indexPath.row]
            let vc = SJThreadViewController()
            vc.link = item.link
            //vc.title = item.title
            vc.fid = currentfid
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
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

extension SJHomeViewController : SJScrollTitleViewDataSource, SJScrollTitleViewDelegate{
    func numberOfMenus() -> Int {
        return menus.count
    }
    
    func titleAtIndex(index: Int) -> String {
        return menus[index]["name"] as! String
    }
    
    func didSelectedIndexOfTitle(view: SJScrollTitleView, index: Int) {
        let selectItem = menus[index]
        let typeid = Int(selectItem["typeid"] as! String)
        page = 1
        currenttypeid = typeid!
        tableView_root.setContentOffset(CGPointZero, animated:true)
        loadData(currentfid, typeid: typeid!)
    }
}
