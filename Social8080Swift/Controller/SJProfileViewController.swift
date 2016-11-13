//
//  SJProfileViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJProfileViewController: SJViewController {

    private var manager = SJProfileViewManager()
    
    private lazy var tableView : UITableView = { [unowned self] in
        let v = UITableView(frame: ccr(0,180,ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT - 180),
                            style: .Grouped)
        v.delegate = self
        v.dataSource = self
        v.scrollEnabled = false
        v.registerClass(SJProfileTableViewCell.self, forCellReuseIdentifier: "profilecell")
        return v
    }()
    
    private lazy var backBtn : UIButton = {
        let b = UIButton(type: .Custom)
        b.setImage(UIImage.init(named: "icon_back") , forState: .Normal)
        b.handleControlEvent(.TouchUpInside, closure: { [weak self] in
            self!.navigationController?.popViewControllerAnimated(true)
        })
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.fd_prefersNavigationBarHidden = true
        //self.navigationController?.navigationBarHidden = true
        manager.setupProfileAtContain(view, loginHandle: { [weak self] in
            if SJClient.sharedInstance.user == nil{  //登录
                let vc = SJLoginViewController()
                vc.loginSuccessAction = { [weak self] (user) in
                    self!.manager.updateView(user)   //更新profile页的头像与状态
                    appdelegate().homeViewController.updateLoginState(user)  //更新home页的头像按钮
                }
                self!.presentViewController(vc, animated: true, completion: {
                    
                })
            }else{  //注销
                SJClient.sharedInstance.doLogout({[weak self] (finish) in
                    self!.manager.updateView(nil)
                    appdelegate().homeViewController.updateLoginState(nil)
                    })
            }
            }) { [weak self] in //设置
                let vc = SJSettingsViewController()
                self!.navigationController?.pushViewController(vc, animated: true)
        }
        
        view.addSubview(backBtn)
        backBtn.snp_makeConstraints { (make) in
            make.size.equalTo(ccs(30, 30))
            make.left.equalTo(10)
            make.top.equalTo(28)
        }
        
        
        view.addSubview(tableView)
        
        if let u = SJClient.sharedInstance.user{ //如果已经登录, 就更新profileview
            manager.updateView(u)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.hidden = true
        //self.navigationController?.navigationBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.navigationBar.hidden = false
        //self.navigationController?.navigationBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .Portrait
    }
}

extension SJProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return 3
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
                cell.title.text = "我的消息"
                cell.icon.image = UIImage(named: "icon_profile_message")
            }else if indexPath.row == 1{
                cell.title.text = "我的提醒"
                cell.icon.image = UIImage(named: "icon_profile_notice")
            }
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("profilecell") as! SJProfileTableViewCell
            cell.accessoryType = .DisclosureIndicator
            if indexPath.row == 0{
                cell.title.text = "我的足迹"
                cell.icon.image = UIImage(named: "icon_profile_footer")
            }else if indexPath.row == 1{
                cell.title.text = "我的贴子"
                cell.icon.image = UIImage(named: "icon_profile_thread")
            }else if indexPath.row == 2{
                cell.title.text = "我的收藏"
                cell.icon.image = UIImage(named: "icon_profile_favour")
            }
            return cell
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
        if indexPath.section == 0{
            if indexPath.row == 0 {
                let message = SJMessageListViewController()
                navigationController?.pushViewController(message, animated: true)
            }else if indexPath.row == 1{
                let notice = SJNoticesViewController()
                navigationController?.pushViewController(notice, animated: true)
            }
        }else if indexPath.section == 1{
        
        }else{
            dprint("退出")
            SJClient.sharedInstance.doLogout { [weak self] (finish) in
                if finish {
                    
                    self!.tabBarController?.selectedIndex = 0
                    
                }else{
                    
                }
            }
        }
    }
}
