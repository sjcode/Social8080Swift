//
//  SJMineViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

class SJMineViewController: SJViewController {
    private lazy var tableView : UITableView = { [unowned self] in
        let v = UITableView(frame: self.view.bounds, style: .Grouped)
        v.delegate = self
        v.dataSource = self
        v.registerClass(SJProfileTableViewCell.self, forCellReuseIdentifier: "profilecell")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
        view.addSubview(tableView)
        
    }
}

extension SJMineViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            return 1
        }else if section == 2{
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("profilecell") as! SJProfileTableViewCell
            cell.accessoryType = .DisclosureIndicator
            if indexPath.row == 0{
                cell.title.text = "我的足迹"
                cell.icon.image = UIImage(named: "icon_settings_footer")
            }else if indexPath.row == 1{
                cell.title.text = "我的贴子"
                cell.icon.image = UIImage(named: "icon_settings_note")
            }else if indexPath.row == 2{
                cell.title.text = "我的收藏"
                cell.icon.image = UIImage(named: "icon_settings_favour")
            }
            return cell
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                var cell = tableView.dequeueReusableCellWithIdentifier("exit")
                if cell == nil{
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "exit")
                    cell?.accessoryType = .None
                    let label = UILabel()
                    label.text = "清除缓存"
                    label.textColor = UIColor ( red: 0.1118, green: 0.1118, blue: 0.1118, alpha: 1.0 )
                    label.font = defaultFont(18)
                    label.sizeToFit()
                    
                    cell?.addSubview(label)
                    label.snp_makeConstraints(closure: { (make) in
                        make.center.equalTo(cell!)
                    })
                }
                return cell!
            }
        }else if indexPath.section == 2 {
            if indexPath.row == 0{
                var cell = tableView.dequeueReusableCellWithIdentifier("exit")
                if cell == nil{
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "exit")
                    cell?.accessoryType = .None
                    let label = UILabel()
                    label.text = "退 出"
                    label.textColor = UIColor ( red: 0.1118, green: 0.1118, blue: 0.1118, alpha: 1.0 )
                    label.font = defaultFont(18)
                    label.sizeToFit()
                    
                    cell?.addSubview(label)
                    label.snp_makeConstraints(closure: { (make) in
                        make.center.equalTo(cell!)
                    })
                }
                return cell!
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dprint("退出")
        SJClient.sharedInstance.doLogout { [weak self] (finish) in
            if finish {
                
                self!.tabBarController?.selectedIndex = 0
                
            }else{
                
            }
        }
    }
}

