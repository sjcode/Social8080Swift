//
//  SJNoticesViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

enum SJNoticeType {
    case NewNotice,OldNotice
}

class SJNoticesViewController: SJViewController {
    var message_page : Int = 1
    var notice_page : Int = 1
    var noticeArray = [SJNoticeModel]()
    var noticeType : SJNoticeType = .NewNotice{
        didSet{
            self.tableView_notice.mj_header.beginRefreshing()
        }
    }
    private lazy var tableView_notice : UITableView = { [unowned self] in
        let v = UITableView(frame: ccr(0, 30, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds) - 30 ), style: .Plain)
        
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
        let menubar = SJScrollTitleView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        menubar.delegate = self
        menubar.datasource = self
        return menubar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "提醒"
        view.addSubview(menuBar)
        view.addSubview(tableView_notice)
        menuBar.reloadMenus()
        tableView_notice.mj_header.beginRefreshing()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
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

extension SJNoticesViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJMessageTableViewCell", forIndexPath: indexPath) as! SJMessageTableViewCell
        cell.configCell(noticeArray[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let notice = noticeArray[indexPath.row]
        var thread = SJThreadModel()
        thread.tid = notice.tid
        let vc = SJThreadViewController()
        vc.threadModel = thread
        navigationController?.pushViewController(vc, animated: true)
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

extension SJNoticesViewController : SJScrollTitleViewDataSource, SJScrollTitleViewDelegate{
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
