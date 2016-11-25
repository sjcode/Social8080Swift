//
//  SJProfileViewController.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit
import RKNotificationHub
class SJProfileViewController: SJViewController {

    private var manager = SJProfileViewManager()
    
    private var menuDatas : [[SJProfileMenuItem]] = [
        [
            SJProfileMenuItem(key: SJProfileKey.Message,icon: "icon_profile_message", title: "我的消息", state: .Offline, controller: "SJMessageListViewController"),
            
            SJProfileMenuItem(key: .Notice, icon: "icon_profile_notice", title: "我的提醒", state: .Offline, controller: "SJNoticesViewController"),
        ],
        [
            SJProfileMenuItem(key: .Footer, icon: "icon_profile_footer", title: "我的足迹", state: .Offline, controller: "SJMyFooterViewController"),
            SJProfileMenuItem(key: .MyThreads, icon: "icon_profile_thread", title: "我的贴子", state: .Offline, controller: "SJMyThreadsViewController"),
            SJProfileMenuItem(key: .MyThreads, icon: "icon_profile_favour", title: "我的收藏", state: .Offline, controller: "SJFavoursViewController"),
        ]
    ]

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
        title = "设置"
        navigationController!.fd_prefersNavigationBarHidden = true
        manager.setupProfileAtContain(view, loginHandle: { [weak self] in
            if SJClient.sharedInstance.user == nil{  //登录
                let vc = SJLoginViewController()
                vc.loginSuccessAction = { [weak self] (user) in
                    self!.manager.updateView(user)   //更新profile页的头像与状态
                    appdelegate().homeViewController.updateLoginState(user)  //更新home页的头像按钮
                    self!.updateMenu(.Online)
                }
                self!.presentViewController(vc, animated: true, completion: {
                    
                })
            }else{  //注销
                SJClient.sharedInstance.doLogout({[weak self] (finish) in
                    self!.manager.updateView(nil)
                    appdelegate().homeViewController.updateLoginState(nil)
                    self!.updateMenu(.Offline)
                    
//                    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//                    for (NSHTTPCookie *each in cookieStorage.cookies) {
//                        [cookieStorage deleteCookie:each];
//                    }
                    
                    if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies{
                        for each in cookies{
                            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(each)
                        }
                    }
                    })
            }
            }) { [weak self] in //设置
                let vc = SJSettingsViewController()
                vc.logoutAction = { [weak self] in
                    SJClient.sharedInstance.user = nil
                    self!.manager.updateView(nil)
                    appdelegate().homeViewController.updateLoginState(nil)
                    self!.updateMenu(.Offline)
                }
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
            self.updateMenu(.Online)
        }
    }
    
    func updateMenu(state: SJProfileState){
        
        switch state {
        case .Online:
            for section in menuDatas {
                for (_,item) in section.enumerate(){
                    item.state = SJProfileState.Online
                }
            }
            break
            
        
        case .Offline:
            for section in menuDatas {
                for (_,item) in section.enumerate(){
                    item.state = SJProfileState.Offline
                }
            }
            break
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        return menuDatas.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDatas[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profilecell") as! SJProfileTableViewCell
        let item = menuDatas[indexPath.section][indexPath.row]
        cell.selectionStyle = item.state == .Offline ? .None : .Default
        cell.configCell(item)
        cell.tapHandle = { (item) in
            dprint("点了 \(item.title)")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 0 && indexPath.row == 0{
//            let displayCell = cell as! SJProfileTableViewCell
//            let hub = RKNotificationHub(view: displayCell.title)
//            let x = CGRectGetMaxX(displayCell.title.bounds) + 5
//            let y = CGRectGetMidY(displayCell.title.bounds) - 13
//            hub.setCircleAtFrame(ccr(x, y, 15, 15))
//            hub.increment()
//        }
//        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = menuDatas[indexPath.section][indexPath.row]
        guard item.state != .Offline else{
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vcclass = NSClassFromString("Social8080Swift." + item.controller) as! UIViewController.Type
        let vc = vcclass.init()
        navigationController!.pushViewController(vc, animated: true)
    }
}
