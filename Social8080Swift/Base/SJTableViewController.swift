//
//  SJTableViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh

class SJTableViewController: SJViewController {
    var dataArray : Array<AnyObject> = ["涵涵" as AnyObject,"大黄猫" as AnyObject,"小花猫" as AnyObject]
    lazy var tableView : UITableView = {
        let v = UITableView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT - ControlSize.TABBAR_HEIGHT), style: .Grouped)
        v.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        v.delegate = self
        v.dataSource = self
        let refresh = v.mj_header
        let f = refresh.frame
        //let newframe = ccr(f.origin.x, f.origin.y - 20, f.size.width, f.size.height)
        //v.mj_header.frame = newframe
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    func loadData(){
        NSThread.sleepForTimeInterval(1)
        tableView.mj_header.endRefreshing()
        tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension SJTableViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell?.textLabel?.text = dataArray[(indexPath as NSIndexPath).row] as? String
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}
