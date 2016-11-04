//
//  SJChooseCategoryViewController.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/4.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

protocol SJChooseCategoryDataSource : NSObjectProtocol {
    func numberOfMenus(vc : SJChooseCategoryViewController) -> Int
    func titleAtIndex(vc : SJChooseCategoryViewController, index : Int) -> String
}

protocol SJChooseCategoryDelegate : NSObjectProtocol {
    func didSelectedIndexOfTitle(vc : SJChooseCategoryViewController, index : Int)
}

public class SJChooseCategoryViewController : UIViewController {
    
    weak var delegate : SJChooseCategoryDelegate?
    weak var datasource : SJChooseCategoryDataSource?
    
    private lazy var tableView : UITableView = {
        let v = UITableView(frame: CGRectMake(0, 0, ScreenSize.SCREEN_WIDTH - 100, CGFloat((self.datasource?.numberOfMenus(self))! * 40 + 30)), style: .Grouped)
        v.center = self.view.center
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.showsVerticalScrollIndicator = false
        v.scrollEnabled = false
        v.delegate = self
        v.dataSource = self
        v.rowHeight = 40
        v.separatorInset = UIEdgeInsetsZero
        v.tableFooterView = UIView()
        v.backgroundColor = UIColor(hexString: "#28384D")
        v.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = false
        v.layer.shadowOpacity = 0.7
        v.layer.shadowRadius = 15
        v.layer.shadowColor = UIColor.blackColor().CGColor
        v.layer.shadowOffset = CGSizeMake(5, 5)
        return v
    }()
    
    private lazy var maskDarkView : UIView = { [unowned self] in
        let v = UIView(frame: self.view.bounds)
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.backgroundColor = UIColor.init(white: 0.126, alpha: 0.5)
        v.addTapEventHandle { [weak self ](gesture) in
            self!.hide()
        }
        return v
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(maskDarkView)
        view.addSubview(tableView)
    }
    
    public func showInView(aView : UIView){
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
        showAnimation()
    }
    
    private func showAnimation(){
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
        view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        view.alpha = 0
        UIView.animateWithDuration(0.25) { [weak self] in
            self!.view.alpha = 1.0
            self!.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    public func hide(){
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            self!.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        }) { [weak self] (finished : Bool) in
            if finished{
                self!.view.removeFromSuperview()
            }
        }
    }
}

extension SJChooseCategoryViewController : UITableViewDataSource, UITableViewDelegate{

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectMake(0,0, 100, 30))
        v.backgroundColor = UIColor ( red: 0.1335, green: 0.1823, blue: 0.2519, alpha: 1.0 )
        let l = UILabel(frame: v.frame)
        l.text = "请选择主题"
        l.font = defaultFont(16)
        l.textColor = UIColor.whiteColor()
        v.addSubview(l)
        return v
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = datasource?.numberOfMenus(self){
            return count
        }else{
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = defaultFont(16)
        let title = datasource?.titleAtIndex(self, index : indexPath.row)
        cell.textLabel?.text = title
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.didSelectedIndexOfTitle(self, index: indexPath.row)
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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

