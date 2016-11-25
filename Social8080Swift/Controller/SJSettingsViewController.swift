//
//  SJSettingsViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/11/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

typealias LogoutAction = ()->()
class SJSettingsViewController: SJViewController {
    
    private lazy var cachesize : String = "0.0mb"
    var logoutAction : LogoutAction?
    
    private lazy var tableView : UITableView = { [unowned self] in
        let v = UITableView(frame: self.view.bounds,
                            style: .Grouped)
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJSettingValueTableViewCell.self, forCellReuseIdentifier: "settingvaluecell")
        v.registerClass(SJSettingButtonTableViewCell.self, forCellReuseIdentifier: "settingbuttoncell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        
        
        let cache = KingfisherManager.sharedManager.cache
        cache.calculateDiskCacheSizeWithCompletionHandler { [weak self] (size) in
            let size = String(size/1024/1024)
            self!.cachesize = size + "mb"
            self!.tableView.reloadData()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
}

extension SJSettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("settingvaluecell", forIndexPath: indexPath) as! SJSettingValueTableViewCell
            cell.title.text = "清理空间"
            cell.value.text = cachesize
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("settingbuttoncell", forIndexPath: indexPath) as! SJSettingButtonTableViewCell
            cell.title.text = "退出"
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            clearCache()
        }else if indexPath.section == 1{
            let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            SJClient.sharedInstance.doLogout({ (finish) in
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "已退出"
                progressHUD.completionBlock = { [weak self] in
                    if let block = self!.logoutAction{
                        block()
                    }
                    self!.navigationController?.popViewControllerAnimated(true)
                }
                progressHUD.hide(true, afterDelay: 1)
            })
        }
    }
    
    func clearCache(){
        let progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.labelText = "清理中"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            let cache = KingfisherManager.sharedManager.cache
            cache.clearDiskCache()
            sleep(3)
            dispatch_async(dispatch_get_main_queue(), { 
                progressHUD.customView = UIImageView.init(image: UIImage.init(named: "icon_progress_successed"))
                progressHUD.mode = .CustomView
                progressHUD.labelText = "清理完成"
                progressHUD.completionBlock = { [weak self] in
                    self!.cachesize = "0mb"
                    self!.tableView.reloadData()
                }
                progressHUD.hide(true, afterDelay: 1)
            })
            
        }
        
    }
}
