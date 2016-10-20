//
//  SJThreadViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh

class SJThreadViewController: SJViewController {
    var link : String?
    var page : Int = 1
    var dataArray = [SJPostModel]()
    var lastArray = [SJPostModel]()
    
    
    
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT), style: .Plain)
        v.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadData(self.link!)
        })
        v.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            self.page = self.page+1
            self.loadData(self.link!)
        })
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
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadData(link : String){
        SJClient.sharedInstance.getPostList(link, page: page) { [weak self](posts) in
            if self!.page == 1{
                self!.dataArray = posts
            }else{
                if self!.lastArray.count != posts.count{
                    self!.dataArray.appendContentsOf(posts)
                }else{
                    let b = self!.lastArray.elementsEqual(posts, isEquivalent: { (src, dest) -> Bool in
                        let b = src.postid == dest.postid
                        dprint("result \(b)")
                        return b
                    })
                    dprint("b == \(b)")
                    if !b {
                        self!.dataArray.appendContentsOf(posts)
                    }else{
                        dprint("没有更多的数据了")
                    }
                }
            }
            self!.lastArray = posts
            self!.tableView .reloadData()
            self!.tableView.mj_header.endRefreshing()
            self!.tableView.mj_footer.endRefreshing()
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
        let height = SJThreadTableViewCell.calculateCellHeight(dataArray[indexPath.row])

        return height
    }
    
    
}
