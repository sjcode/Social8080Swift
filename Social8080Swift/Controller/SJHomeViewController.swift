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

class SJHomeViewController: UIViewController {
    
    var dataArray = [SJThreadModel]()
    var page : Int = 1
    var currentfid : Int = 85{
        didSet{
            loadMenus(currentfid)
            menuBar.reloadMenus()
        }
    }
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
        v.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.page = 1
            self.loadData(self.currentfid, typeid: -1)
        })
        v.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            self.page = self.page+1
            self.loadData(self.currentfid,typeid: self.currenttypeid)
        })
        v.rowHeight = 62
        //v.separatorInset = UIEdgeInsetsZero
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
        v.registerClass(SJForumTableViewCell.self, forCellReuseIdentifier: "SJForumTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentControl
        view.addSubview(scrollView)
        scrollView.addSubview(menuBar)
        scrollView.addSubview(tableView_root)
        scrollView.addSubview(tableView_forum)
        
        currentfid = 85
        
        tableView_root.mj_header.beginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadData(fid : Int, typeid : Int){
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.label.text = "加载中..."

        SJClient.sharedInstance.getThreadList(fid, typeid : typeid , page: page) { [weak self] (threads) in
            if self!.page == 1{
                self!.dataArray = threads
            }else{
                self!.dataArray.appendContentsOf(threads)
            }
            progressHud.hideAnimated(true)
            self!.tableView_root.reloadData()
            self!.tableView_root.mj_header.endRefreshing()
            self!.tableView_root.mj_footer.endRefreshing()
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
}

extension SJHomeViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView_root{
            return dataArray.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == tableView_root{
            let cell = tableView.dequeueReusableCellWithIdentifier("SJHomeTableViewCell", forIndexPath: indexPath) as! SJHomeTableViewCell
            cell.configCell(dataArray[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SJForumTableViewCell", forIndexPath: indexPath) as! SJForumTableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = dataArray[indexPath.row] 
        let vc = SJThreadViewController()
        vc.link = item.link
        vc.title = item.title
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if(tableView.respondsToSelector(Selector("setSeparatorInset:"))){
//            tableView.separatorInset = UIEdgeInsetsZero
//        }
//        
//        if(tableView.respondsToSelector(Selector("setLayoutMargins:"))){
//            tableView.layoutMargins = UIEdgeInsetsZero
//        }
//        
//        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
//            cell.layoutMargins = UIEdgeInsetsZero
//        }
//    }
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
