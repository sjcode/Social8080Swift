//
//  SJForumViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import Kanna
import WMPageController_Swift

class SJForumViewController: SJViewController {
    var dataArray = [SJThreadModel]()
    var page : Int = 1
    
    lazy var tableView : UITableView = {
        let v = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT - 64), style: .Plain)
        v.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadData(1)
        })
        v.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.page = self.page+1
            self.loadData(self.page)
        })
        v.rowHeight = 62
        v.separatorInset = UIEdgeInsetsZero
        v.delegate = self
        v.dataSource = self
        let refresh = v.mj_header
        refresh.tintColor = UIColor.redColor()
        
        let f = refresh.frame
        v.registerClass(SJHomeTableViewCell.self, forCellReuseIdentifier: "SJHomeTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.addSubview(tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //tableView.mj_header.beginRefreshing()
    }
    
    func loadData(page : Int){
//        SJClient.sharedInstance.getForumList(159, page: page) { [weak self] (threads) in
//            if self!.page == 1{
//                self!.dataArray = threads
//            }else{
//                self!.dataArray.appendContentsOf(threads)
//            }
//            
//            self!.tableView.reloadData()
//            self!.tableView.mj_header.endRefreshing()
//        }
    }
}

extension SJForumViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJHomeTableViewCell", forIndexPath: indexPath) as! SJHomeTableViewCell
        cell.configCell(dataArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
