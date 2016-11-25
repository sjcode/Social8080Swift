//
//  SJForumPanel.swift
//  Social8080Swift
//
//  Created by sujian on 11/12/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

typealias ClickItemAction = (fid: Int) -> ()

class SJForumPanel: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        //backgroundColor = UIColor ( red: 0.1264, green: 0.1264, blue: 0.1264, alpha: 1.0 )
        //layer.borderColor = UIColor ( red: 0.4266, green: 0.4758, blue: 0.4803, alpha: 1.0 ).CGColor
        //layer.borderWidth = 0.5
        alpha = 0
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SJForumPanelManager : NSObject {
    var forumPanel : UITableView!
    var clickItemAction : ClickItemAction?
    var dataArray : NSArray!
    var height : CGFloat!
    var cells = [UITableViewCell]()
    
    override init(){
        super.init()
        if let path = NSBundle.mainBundle().pathForResource("forumtable", ofType: "plist"){
            if let entireArray = NSArray(contentsOfFile: path){
                dataArray = entireArray
                for item in dataArray{
                    let section = item["array"] as! NSArray
                    let cell = UITableViewCell(style: .Default, reuseIdentifier: "")
                    cell.backgroundColor = UIColor.clearColor()
                    cell.selectionStyle = .None
                    self.addButtons(cell, array: section)
                    cells.append(cell)
                }
            }
        }
    }
    
    func calcuatePanelHeight() -> CGFloat{
        var height : CGFloat = 0
        for forums in dataArray{
            height += calcuateEachCellHeight(forums as! NSDictionary, includeHeader: true)
        }
        return height
    }
    
    func setupPanelAtContainer(view: UIView, clickItemAction: ClickItemAction?){
        forumPanel = SJForumPanel(frame: ccr(0, 64, ScreenSize.SCREEN_WIDTH, calcuatePanelHeight()), style: .Plain)
        forumPanel.backgroundColor = UIColor ( red: 0.1264, green: 0.1264, blue: 0.1264, alpha: 1.0 )
        forumPanel.separatorStyle = .None
        forumPanel.tableFooterView = UIView()
        forumPanel.dataSource = self
        forumPanel.delegate = self
        forumPanel.hidden = true
        self.clickItemAction = clickItemAction
        view.addSubview(forumPanel)
        view.bringSubviewToFront(forumPanel)
        
        
    }
    
    func showPanel(show: Bool, complete : ()->()){
        forumPanel.hidden = show ? false : true
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            self!.forumPanel.alpha = show ? 0.9 : 0
            }) { (finish) in
                complete()
        }
    }
    
    func addButtons(cell: UITableViewCell, array: NSArray){
        var x : CGFloat = 5
        var y : CGFloat = 5

        let labelfont = defaultFont(10)
        
        let labelwidth : CGFloat = (ScreenSize.SCREEN_WIDTH - (MARGIN*2) - (SPANCING*2))/3
        let labelheight : CGFloat = PANEL_BUTTON_HEIGHT
        for (index,item) in array.enumerate() {
            let title = item["title"] as! String
            let i = index
            let m = Int(i / Int(MAX_LINE_ROW))
            if m == 0{
                let j : CGFloat = (CGFloat(i) % PANEL_MAX_LINE_ROW)
                x = labelwidth * j as CGFloat + (j == 0 ? 0 : j*SPANCING) + 8
                y = 8
            }else{
                let j : CGFloat = CGFloat(i) % PANEL_MAX_LINE_ROW
                x = labelwidth * j + (j == 0 ? 0 : j * SPANCING) + 8
                y = CGFloat(m) * labelheight + (CGFloat(m) * SPANCING) + 8
            }
            
            let button = UIButton(type: .System)
            button.frame = ccr(x, y, labelwidth, labelheight)
            button.titleLabel?.font = labelfont
            button.backgroundColor = UIColor ( red: 0.1118, green: 0.1118, blue: 0.1118, alpha: 1.0 )
            let fid = item["fid"] as! NSString
            button.tag = Int(fid as String)!
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 0.3
            button.layer.cornerRadius = 10
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.setTitle(title, forState: .Normal)
            
            button.addTarget(self, action: #selector(clickforum(_:)), forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(button)
        }
    }
    
    func calcuateEachCellHeight(forums: NSDictionary, includeHeader: Bool) -> CGFloat{
        var height = 0
        let margin = MARGIN
        let array = forums["array"] as! NSArray
        let remain = array.count % 3
        var line = array.count / 3
        if remain > 0 {
            line += 1
        }
        
        height = Int(margin) * 2// + (line * PANEL_BUTTON_HEIGHT) + ((line - 1) * SPANCING)
        height += line * Int(PANEL_BUTTON_HEIGHT)
        height += ((line - 1) * Int(SPANCING))
        
        if includeHeader {
            height += 30
        }
        return CGFloat(height)
    }
    
    func clickforum(sender: UIButton){
        if let block = clickItemAction {
            forumPanel.hidden = true
            
            block(fid: sender.tag)
        }
    }
    
    
    let MARGIN : CGFloat = 5
    let SPANCING : CGFloat = 5
    let PANEL_MAX_LINE_ROW : CGFloat = 3
    let CELL_HEADER_HEIGHT : CGFloat = 20
    let PANEL_BUTTON_HEIGHT : CGFloat = 25
}

extension SJForumPanelManager : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: ccr(0, 0, ScreenSize.SCREEN_WIDTH, CELL_HEADER_HEIGHT))
        v.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        let l = UILabel(frame: ccr(0, 0, 150, 18))
        l.textColor = UIColor.whiteColor()
        l.font = boldFont(12)
        let sec = dataArray[section] as! NSDictionary
        l.text = sec["title"] as? String
        v.addSubview(l)
        l.snp_makeConstraints { (make) in
            make.left.equalTo(v).offset(8)
            make.centerY.equalTo(v)
        }
        
        return v
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CELL_HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let forums = dataArray[indexPath.section] as! NSDictionary
        return calcuateEachCellHeight(forums, includeHeader: false) + 5
    }
}






