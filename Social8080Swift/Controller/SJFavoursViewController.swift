//
//  SJFavoursViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/16/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

enum SJFavourType {
    case Forum,Thread
}
class SJFavoursViewController: SJViewController {

    var dataArray = [SJFavourModel]()
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
        v.tableFooterView = UIView()
        v.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        v.separatorStyle = .None
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJFavourTableViewCell.self, forCellReuseIdentifier: "SJFavourTableViewCell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "我的收藏"
        view.addSubview(tableView)
        
        tableView.mj_header.beginRefreshing()
    }
    
    func loadData(){
        SJClient.sharedInstance.getFavourList(type, page: page, completeHandle: { [weak self] (finish, favours) in
            if finish{
                if self!.page == 1{
                    self!.dataArray = favours
                }else{
                    if favours.count > 0{
                        self!.dataArray.appendContentsOf(favours)
                    }else{
                        self!.page = 1
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
        })
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
}

extension SJFavoursViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJFavourTableViewCell", forIndexPath: indexPath) as! SJFavourTableViewCell
        
        let favour = dataArray[indexPath.row]
        cell.configCell(favour)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44+15
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = dataArray[indexPath.row]
        let vc = SJThreadViewController()
        
        var thread = SJThreadModel()
        thread.link = item.link
        thread.title = item.title
        vc.threadModel = thread
        vc.link = item.link
        navigationController?.pushViewController(vc, animated: true)
    }
}
