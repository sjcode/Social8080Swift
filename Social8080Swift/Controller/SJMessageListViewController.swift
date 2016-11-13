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




class SJMessageListViewController: SJViewController {
    var message_page : Int = 1
    var messageArray = [SJMessageModel]()
    var lastMessageArray = [SJMessageModel]()
    
    private lazy var tableView_message : UITableView = { [unowned self] in
        let v = UITableView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, CGRectGetHeight(self.view.bounds)), style: .Plain)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消息"
        view.addSubview(tableView_message)
        tableView_message.mj_header.beginRefreshing()
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
    
    
}

extension SJMessageListViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJMessageTableViewCell", forIndexPath: indexPath) as! SJMessageTableViewCell
        cell.configCell(messageArray[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = SJMessageDetailViewController()
        vc.model = messageArray[indexPath.row]
        navigationController!.pushViewController(vc, animated: true)
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

