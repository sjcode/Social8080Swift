//
//  SJMyThreadsViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/16/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

class SJMyThreadsViewController: SJViewController {

    var dataArray = [SJThreadModel]()
    var page : Int = 1
    var type : SJFavourType = .Thread
    
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: ccr(0, 0 , ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT - 64 ), style: .Plain)
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self!.page = 1
            self!.loadData()
            })
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self!.page = self!.page+1
            self!.loadData()
            })
        
        footer.automaticallyHidden = true
        footer.refreshingTitleHidden = true
        footer.setTitle("", forState: .Idle)
        v.mj_header = header
        v.mj_footer = footer
        v.rowHeight = 44 + 15
        v.tableFooterView = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        v.separatorStyle = .None
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJMyThreadsTableViewCell.self, forCellReuseIdentifier: "SJMyThreadsTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "我的贴子"
        view.addSubview(tableView)
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadData(){
        SJClient.sharedInstance.getMyThreadList(page) { [weak self] (finish, threads) in
            if finish{
                if self!.page == 1{
                    self!.dataArray = threads
                }else{
                    if threads.count > 0{
                        self!.dataArray.appendContentsOf(threads)
                    }else{
                        self!.page -= 1
                        alertmessage(self!.view, message: "没有更多的数据了")
                    }
                }
                self!.tableView.reloadData()
                self!.tableView.mj_header.endRefreshing()
                self!.tableView.mj_footer.endRefreshing()
            }else{
                let progressHUD = MBProgressHUD.showHUDAddedTo(self!.view, animated: true)
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_failed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "网络不给力"
                progressHUD.hide(true, afterDelay: 1)
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
}

extension SJMyThreadsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJMyThreadsTableViewCell", forIndexPath: indexPath) as! SJMyThreadsTableViewCell
        let item = dataArray[indexPath.row]
        cell.configCell(item)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = SJThreadViewController()
        vc.threadModel = dataArray[indexPath.row]
        navigationController!.pushViewController(vc, animated: true)
    }
}