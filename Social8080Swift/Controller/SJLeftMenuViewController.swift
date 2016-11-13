//
//  SJLeftMenuViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import SnapKit

class SJLeftMenuViewController: SJViewController {
    
    private var forumtable : NSArray!
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: ccr(0,
            100,
            ScreenSize.SCREEN_WIDTH,
            ScreenSize.SCREEN_HEIGHT - 100),
                            style: .Plain)
        v.backgroundColor = UIColor.clearColor()
        v.separatorStyle = .None
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bkImage = UIImage(named: "leftview_bg")?.resizedImageWithBounds(view.bounds.size)
        
        view.backgroundColor = UIColor(patternImage: bkImage!)
        
        loadForumCell()
        view.addSubview(tableView)
        view.clipsToBounds = true //防止tableview超出父类
    }
    
    func loadForumCell() {
        if let path = NSBundle.mainBundle().pathForResource("forumtable", ofType: "plist"){
            if let entireArray = NSArray(contentsOfFile: path){
                forumtable = entireArray
            }
        }
    }
    
    func storelastfid(fid: String){
        NSUserDefaults.standardUserDefaults().setValue(fid, forKey: "currentfid")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

extension SJLeftMenuViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return forumtable!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = forumtable![section] as! NSDictionary
        return (sec["array"] as! NSArray).count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor.whiteColor()
            cell!.textLabel?.font = defaultFont(14)

            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
            cell!.selectedBackgroundView = bgColorView
        }
        let sec = forumtable![indexPath.section] as! NSDictionary
        let forums = sec["array"] as! NSArray
        let forum = forums[indexPath.row] as! NSDictionary
        cell!.textLabel!.text = forum["title"] as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, 30))
        v.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        let l = UILabel(frame: ccr(0, 0, 150, 25))
        l.textColor = UIColor.whiteColor()
        l.font = boldFont(18)
        let sec = forumtable![section] as! NSDictionary
        l.text = sec["title"] as? String
        v.addSubview(l)
        l.snp_makeConstraints { (make) in
            make.left.equalTo(v).offset(8)
            make.centerY.equalTo(v)
        }
        
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let section = forumtable![indexPath.section] as! NSDictionary
        let forum = section["array"] as! NSArray
        let fid = forum[indexPath.row]["fid"] as! String
        if let needlogin = forum[indexPath.row]["needlogin"] where SJClient.sharedInstance.user == nil{
            let b = needlogin as! Bool
            if b {
                let vc = SJLoginViewController()
                vc.loginSuccessAction = {[weak self] (uid) in
                    let home = appdelegate().homeViewController
                    home.currentfid = Int(fid)!
                    self!.storelastfid(fid)
                }
                mm_drawerController.closeDrawerAnimated(true, completion:{ [weak self] (finish) in
                    self!.presentViewController(vc, animated: true, completion: nil)
                })
            }
        }else{
            mm_drawerController.closeDrawerAnimated(true, completion: {[weak self](b) in
                let home = appdelegate().homeViewController
                home.currentfid = Int(fid)!
                self!.storelastfid(fid)
                })
        }
    }
}
