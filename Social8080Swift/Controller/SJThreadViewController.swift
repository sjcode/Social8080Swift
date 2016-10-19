//
//  SJThreadViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh

class SJThreadViewController: UIViewController {
    var link : String?
    var page : Int = 1
    var dataArray = [SJPostModel]()
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT - 64), style: .Plain)
        v.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadData(self.link!)
        })
        v.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.page = self.page+1
            self.loadData(self.link!)
        })
        v.rowHeight = 62
        v.separatorInset = UIEdgeInsetsZero
        v.delegate = self
        v.dataSource = self
        let refresh = v.mj_header
        refresh.tintColor = UIColor.redColor()
        
        let f = refresh.frame
        v.registerClass(SJThreadTableViewCell.self, forCellReuseIdentifier: "SJThreadTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    func loadData(link : String){
        SJClient.sharedInstance.getPostList(link, page: page) { (posts) in
            if self.page == 1{
                self.dataArray = posts
            }else{
                self.dataArray.appendContentsOf(posts)
            }
            self.tableView .reloadData()
            self.tableView.mj_header.endRefreshing()
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
        cell.configCell(item)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}
