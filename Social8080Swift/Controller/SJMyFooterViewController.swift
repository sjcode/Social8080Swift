//
//  SJMyFooterViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/15/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import MJRefresh

class SJMyFooterViewController: SJViewController {
    
    var dataArray = [SJThreadModel]()
    
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: ccr(0, 0 , ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT - 64 ), style: .Plain)
        v.tableFooterView = UIView()
        v.separatorInset = UIEdgeInsetsZero
        v.rowHeight = 62
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJHomeTableViewCell.self, forCellReuseIdentifier: "SJHomeTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的足迹"
        view.addSubview(tableView)
        dataArray = loadThreadFromCoreData()
        tableView.reloadData()
    }
    
    func loadThreadFromCoreData() -> [SJThreadModel]{
        var array = [SJThreadModel]()
        for (_,model) in RecentReadThread.MR_findAll()!.enumerate().reverse(){
            let thread = model as! RecentReadThread
            var obj = SJThreadModel()
            obj.title = thread.title
            obj.author = thread.author
            obj.datetime = thread.datetime
            obj.link = thread.link
            obj.uid = thread.uid
            array.append(obj)
        }
        return array
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
}

extension SJMyFooterViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJHomeTableViewCell", forIndexPath: indexPath) as! SJHomeTableViewCell
        let thread = dataArray[indexPath.row]
        cell.configCell(thread)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = dataArray[indexPath.row]
        let vc = SJThreadViewController()
        vc.threadModel = item
        vc.link = item.link
        //vc.title = item.title
        //vc.fid = currentfid
        navigationController?.pushViewController(vc, animated: true)
    }
}

