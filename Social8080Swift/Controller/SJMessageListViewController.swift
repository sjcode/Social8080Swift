//
//  SJMessageListViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

enum SJNoticeType {
    case NewNotice,OldNotice
}


class SJMessageListViewController: UIViewController {
    var message_page : Int = 1
    var notice_page : Int = 1
    var messageArray = [SJMessageModel]()
    var lastMessageArray = [SJMessageModel]()
    var noticeArray = [SJMessageModel]()
    var noticeType : SJNoticeType = .NewNotice{
        didSet{
            self.tableView_notice.mj_header.beginRefreshing()
        }
    }
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
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT - 64), style: .Plain)
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.message_page = 1
            self!.loadData()
        })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.message_page = self!.message_page+1
            self!.loadData()
            })
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        
        v.separatorInset = UIEdgeInsetsZero
        v.mj_header = header
        v.mj_footer = footer
        v.tableFooterView = UIView()
        v.rowHeight = 50
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJMessageTableViewCell.self, forCellReuseIdentifier: "SJMessageTableViewCell")
        return v
    }()
    
    private lazy var tableView_notice : UITableView = {
        let v = UITableView(frame: CGRect(x: ScreenSize.SCREEN_WIDTH, y: 30, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT -  64 ), style: .Plain)
        
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.notice_page = 1
            self!.loadNotice(self!.noticeType)
            })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.notice_page = self!.notice_page+1
            self!.loadNotice(self!.noticeType)
            })
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        v.separatorInset = UIEdgeInsetsZero
        v.mj_header = header
        v.mj_footer = footer
        v.tableFooterView = UIView()
        v.rowHeight = 50
        v.delegate = self
        v.dataSource = self
        v.separatorInset = UIEdgeInsetsZero
        v.registerClass(SJMessageTableViewCell.self, forCellReuseIdentifier: "SJMessageTableViewCell")
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
        tableView_message.mj_header.beginRefreshing()
    }
    
    //MARK: Action
    func changeTab(sender : UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        scrollView.scrollRectToVisible(CGRect(x: index == 0 ? 0 : view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height-64-49), animated: true)
        if index == 0 {
            tableView_message.mj_header.beginRefreshing()
        }else{
            tableView_notice.mj_header.beginRefreshing()
        }
    }
    
    //MARK: Appearance
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
    
    func loadData(){
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "加载中..."
        SJClient.sharedInstance.getMessageList(message_page, completed: { [weak self] (finish, messages) in
            progressHud.hide(true)
            if finish{
                if self!.message_page == 1{
                    self!.messageArray = messages
                    self!.tableView_message.mj_header.endRefreshing()
                }else{
                    if self!.lastMessageArray.count != messages.count{
                        self!.messageArray.appendContentsOf(messages)
                    }else{
                        let b = self!.lastMessageArray.elementsEqual(messages, isEquivalent: { (src, dest) -> Bool in
                            let b = src.link == dest.link
                            return b
                        })
                        if !b {
                            self!.messageArray.appendContentsOf(messages)
                        }else{
                            dprint("没有更多的数据了")
                            alertmessage(self!.view, message: "没有更多的数据了")
                        }
                    }
                }
                self!.lastMessageArray = messages
                self!.tableView_message.mj_header.endRefreshing()
                self!.tableView_message.mj_footer.endRefreshing()
                self!.tableView_message.reloadData()
                
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        })
    }
    
    func loadNotice(type : SJNoticeType){
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "加载中..."
        
        SJClient.sharedInstance.getNoticeList(type, page : notice_page, completed: { [weak self] (finish, notices) in
            progressHud.hide(true)
            if finish{
                if self!.notice_page == 1{
                    self!.noticeArray = notices
                }else{
                    self!.noticeArray.appendContentsOf(notices)
                }
                self!.tableView_notice.mj_header.endRefreshing()
                self!.tableView_notice.mj_footer.endRefreshing()
                self!.tableView_notice.reloadData()
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        })
    }
}

extension SJMessageListViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == tableView_message{
            let cell = tableView.dequeueReusableCellWithIdentifier("SJMessageTableViewCell", forIndexPath: indexPath) as! SJMessageTableViewCell
            cell.configCell(messageArray[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SJMessageTableViewCell", forIndexPath: indexPath) as! SJMessageTableViewCell
            cell.configCell(noticeArray[indexPath.row])
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView_message{
            return messageArray.count
        }else{
            return noticeArray.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == tableView_message{
            let vc = SJMessageDetailViewController()
            vc.model = messageArray[indexPath.row]
            navigationController!.pushViewController(vc, animated: true)
        }else{
            let item = noticeArray[indexPath.row]
            let vc = SJThreadViewController()
            vc.link = item.link
            vc.title = item.content
            navigationController?.pushViewController(vc, animated: true)
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

extension SJMessageListViewController : SJScrollTitleViewDataSource, SJScrollTitleViewDelegate{
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
        noticeType = index == 0 ? .NewNotice : .OldNotice
    }
}
