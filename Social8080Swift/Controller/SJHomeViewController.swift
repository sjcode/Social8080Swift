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

class SJHomeViewController: UIViewController {
    
    var dataArray = [SJThreadModel]()
    var page : Int = 1
    var currentfid : Int = 85{
        didSet{
            loadMenus(currentfid)
            menuBar.reloadMenus()
        }
    }
    
    var forumTableCells = [UITableViewCell]()
    var currenttypeid : Int = -1
    private var menus = [NSDictionary]()
    
    private lazy var segmentControl : UISegmentedControl = {
        let segment = UISegmentedControl(items: ["首页", "论坛"])
        segment.frame = CGRect(x: 0, y: 0, width: 144, height: 29)
        segment.tintColor = UIColor.whiteColor()
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(changeTab(_:)), forControlEvents: .ValueChanged)
        return segment
    }()
    
    private lazy var menuBar : SJScrollTitleView = {
        let menubar = SJScrollTitleView(frame: CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        menubar.delegate = self
        menubar.datasource = self
        return menubar
    }()
    
    private lazy var scrollView : UIScrollView = {
        let scrollview = UIScrollView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.delegate = self
        scrollview.pagingEnabled = true
        scrollview.bounces = true
        scrollview.contentSize = CGSize(width: self.view.bounds.size.width * 2 , height: scrollview.bounds.size.height-64-49)
        return scrollview
    }()
    
    private lazy var tableView_root : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 30, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT - 64 - 30), style: .Plain)
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
    
    private lazy var tableView_forum : UITableView = {
        let v = UITableView(frame: CGRect(x: ScreenSize.SCREEN_WIDTH, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT -  64 ), style: .Plain)
        v.tableFooterView = UIView()
        v.delegate = self
        v.dataSource = self
        v.separatorInset = UIEdgeInsetsZero
        v.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SJForumTableViewCell")
        return v
    }()
    
    private lazy var leftbutton : UIButton = {
        let b = UIButton(type: .Custom)
        b.frame = CGRectMake(0,0,48,48)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        b.setImage(UIImage.init(named: "person_normal"), forState: .Normal)
        b.addTarget(self, action: #selector(clickperson(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var rightbutton : UIButton = {
        let b = UIButton(type: .System)
        b.frame = CGRectMake(0,0,48,48)
        b.setTitle("发贴", forState: .Normal)
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(clicksend(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    func clickperson(sender : UIButton) {
        let vc = SJLoginViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func clicksend(sender : UIButton){
        let vc = SJWritePostViewController()
        vc.fid = currentfid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentControl
        
        let fixedspace = UIBarButtonItem.init(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedspace.width = -20
        let items = [fixedspace,  UIBarButtonItem(customView: leftbutton)]
        navigationItem.leftBarButtonItems = items
        
        let itmes2 = [fixedspace, UIBarButtonItem(customView: rightbutton)]
        navigationItem.rightBarButtonItems = itmes2
        
        
        loadForumCell()
        
        view.addSubview(scrollView)
        scrollView.addSubview(menuBar)
        scrollView.addSubview(tableView_root)
        scrollView.addSubview(tableView_forum)
        
        if let fid = NSUserDefaults.standardUserDefaults().valueForKey("currentfid"){
            currentfid = Int(fid as! NSNumber)
        }else{
            currentfid = 85
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationLoginSuccess, object: self, queue: NSOperationQueue.mainQueue()) { [weak self](notification) in
            let uid = notification.userInfo!["uid"] as! String
            self?.leftbutton.kf_setImageWithURL(NSURL.init(string: getMiddleAvatarUrl(uid)), forState: .Normal)
            self?.leftbutton.userInteractionEnabled = false
            
        }
        
        SJClient.sharedInstance.tryLoginAndLoadUI(false) { [weak self] (finish, error, uid) in
            if finish{
                if (uid != nil){
                    
                    KingfisherManager.sharedManager.downloader.downloadImageWithURL(NSURL.init(string: getMiddleAvatarUrl(uid!))!, options: [.ForceRefresh], progressBlock: nil, completionHandler: { [weak self](image, error, imageURL, originalData) in
                        if (image != nil){
                            self!.leftbutton.setImage(maskRoundedImage(image!.resizedImageWithBounds(CGSizeMake(30, 30)), radius: 15), forState: .Normal)
                            self!.leftbutton.userInteractionEnabled = false
                        }
                    })
                }
            }
            
            self!.tableView_root.mj_header.beginRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    
    func loadData(fid : Int, typeid : Int){
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.labelText = "加载中..."

        SJClient.sharedInstance.getThreadList(fid, typeid : typeid , page: page) { [weak self] (finish, threads) in
            progressHud.hide(true)
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
    
    func changeTab(sender : AnyObject) {
        let index = sender.selectedSegmentIndex
        scrollView.scrollRectToVisible(CGRect(x: index == 0 ? 0 : view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height-64-49), animated: true)
    }
    
    func loadMenus(fid : Int){
        if let path = NSBundle.mainBundle().pathForResource("forumtable", ofType: "plist"){
            if let entireArray = NSArray(contentsOfFile: path){
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
}

extension SJHomeViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView_root{
            return dataArray.count
        }else{
            return forumTableCells.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == tableView_root{
            let cell = tableView.dequeueReusableCellWithIdentifier("SJHomeTableViewCell", forIndexPath: indexPath) as! SJHomeTableViewCell
            cell.configCell(dataArray[indexPath.row])
            return cell
        }else{
            return forumTableCells[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == tableView_root {
            let item = dataArray[indexPath.row]
            let vc = SJThreadViewController()
            vc.link = item.link
            vc.title = item.title
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableView_root {
            return 62
        }else{
            return forumTableCells[indexPath.row].frame.size.height+5
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

extension SJHomeViewController : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if scrollView.contentOffset.x == ScreenSize.SCREEN_WIDTH {
                segmentControl.selectedSegmentIndex = 1
            }else{
                segmentControl.selectedSegmentIndex = 0
            }
            
        }else{
            
        }
    }
}

extension SJHomeViewController{
    func loadForumCell() {
        if let path = NSBundle.mainBundle().pathForResource("forumtable", ofType: "plist"){
            if let entireArray = NSArray(contentsOfFile: path){
                for section in entireArray {
                    
                    let cell = UITableViewCell(style: .Default, reuseIdentifier: "SJForumTableViewCell")
                    cell.selectionStyle = .None
                    let array = section["array"] as! NSArray
                    addButtonsOnCell(cell, array: array)
                    forumTableCells.append(cell)
                    
                }
            }
        }
    }
    
    
    
    func addButtonsOnCell(cell : UITableViewCell, array: NSArray){
        var x : CGFloat = 8
        var y : CGFloat = 8

        let MARGIN : CGFloat = 8
        let SPANCING : CGFloat = 5
        let labelfont = defaultFont(12)
        let MAX_LINE_ROW : CGFloat = 3
        
        let labelwidth : CGFloat = (ScreenSize.SCREEN_WIDTH - (MARGIN*2) - (SPANCING*2))/3
        let labelheight : CGFloat = 25
        for (index,item) in array.enumerate() {
            let title = item["title"] as! String
            let i = index
            let m = Int(i / Int(MAX_LINE_ROW))
            if m == 0{
                let j : CGFloat = (CGFloat(i) % MAX_LINE_ROW)
                x = labelwidth * j as CGFloat + (j == 0 ? 0 : j*SPANCING) + 8
                y = 8
            }else{
                let j : CGFloat = CGFloat(i) % MAX_LINE_ROW
                x = labelwidth * j + (j == 0 ? 0 : j * SPANCING) + 8
                y = CGFloat(m) * labelheight + (CGFloat(m) * SPANCING) + 8
            }
            
            let button = UIButton(type: .System)
            button.frame = CGRectMake(x, y, labelwidth, labelheight)
            button.titleLabel?.font = labelfont
            let fid = item["fid"] as! NSString
            button.tag = Int(fid as String)!
            button.layer.borderColor = UIColor.grayColor().CGColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)
            button.setTitle(title, forState: .Normal)
            
            button.addTarget(self, action: #selector(clickforum(_:)), forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(button)
        }
        
        var frame = cell.frame
        let line : Int = array.count % 3 == 0 ? array.count/3: array.count/3+1
        let mix = min(line-1, 1)
        frame.size.height = 16 + labelheight * CGFloat(line) + CGFloat(mix)*5
        cell.frame = frame
    }
    
    func clickforum(sender : UIButton) {
        let fid = sender.tag
        dprint("fid - \(fid)")
        
        NSUserDefaults.standardUserDefaults().setInteger(fid, forKey: "currentfid")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        currentfid = fid
        
        let index = 0
        scrollView.scrollRectToVisible(CGRect(x: index == 0 ? 0 : view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height-64-49), animated: true)
        segmentControl.selectedSegmentIndex = 0
        tableView_root.mj_header.beginRefreshing()
    }
}
