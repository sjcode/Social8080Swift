//
//  SJMessageViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

class SJMessageViewController: UIViewController {
    var page : Int = 1
    
    private lazy var segmentControl : UISegmentedControl = {
        let segment = UISegmentedControl(items: ["消息", "提醒"])
        segment.frame = CGRect(x: 0, y: 0, width: 144, height: 29)
        segment.tintColor = UIColor.whiteColor()
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(changeTab(_:)), forControlEvents: .ValueChanged)
        return segment
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
    
    private lazy var tableView_message : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT - 64 - 30), style: .Plain)
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.page = 1
            self!.loadData()
        })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.page = self!.page+1
            
        })
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        v.mj_header = header
        v.mj_footer = footer
        v.tableFooterView = UIView()
        v.rowHeight = 62
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJHomeTableViewCell.self, forCellReuseIdentifier: "SJHomeTableViewCell")
        return v
    }()
    
    private lazy var tableView_notice : UITableView = {
        let v = UITableView(frame: CGRect(x: ScreenSize.SCREEN_WIDTH, y: 30, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT -  64 ), style: .Plain)
        v.tableFooterView = UIView()
        v.delegate = self
        v.dataSource = self
        v.separatorInset = UIEdgeInsetsZero
        v.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SJForumTableViewCell")
        return v
    }()
    
    private lazy var menuBar : SJScrollTitleView = {
        let menubar = SJScrollTitleView(frame: CGRectMake(ScreenSize.SCREEN_WIDTH, 0, ScreenSize.SCREEN_WIDTH, 30))
        menubar.delegate = self
        menubar.datasource = self
        return menubar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentControl
        view.addSubview(scrollView)
        scrollView.addSubview(menuBar)
        scrollView.addSubview(tableView_message)
        scrollView.addSubview(tableView_notice)
        menuBar.reloadMenus()
    }
    
    //MARK: Action
    func changeTab(sender : UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        scrollView.scrollRectToVisible(CGRect(x: index == 0 ? 0 : view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height-64-49), animated: true)
    }
    
    //MARK: Appearance
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    
    func loadData(){
        let progressHud = MBProgressHUD.showHUDAddedTo((navigationController?.view)!, animated: true)
        progressHud.labelText = "加载中..."
        SJClient.sharedInstance.getMessageList { [weak self] (messages) in
            progressHud.hide(true)
            self!.tableView_message.mj_header.endRefreshing()
            self!.tableView_message.mj_footer.endRefreshing()
        }
    }
}

extension SJMessageViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension SJMessageViewController : SJScrollTitleViewDataSource, SJScrollTitleViewDelegate{
    func numberOfMenus() -> Int {
        return 2
    }
    
    func titleAtIndex(index: Int) -> String {
        if index == 0{
            return "新的提醒"
        }else{
            return "已读提醒"
        }
    }
    
    func didSelectedIndexOfTitle(view: SJScrollTitleView, index: Int) {
        dprint("click \(index)")
    }
}
