//
//  SJPopMenu.swift
//  Social8080Swift
//
//  Created by sujian on 16/12/4.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

final class SJPopItemCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    private lazy var label: UILabel = {
        let l = UILabel(frame: ccr(0, 0, 80, 30))
        //l.font =
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp_makeConstraints { [weak self] (make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class SJPopMenu: UIView {
    
    private let rowHeight: CGFloat = 30
    private let menuWidth: CGFloat = 100.0
    
    private var menuHeight: CGFloat {
        return CGFloat(items.count) * rowHeight
    }
    
    private var items: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    static let shareMenu: SJPopMenu = SJPopMenu()
    
    static func showMenu(view: UIView, fromRect: CGRect, items: [String]) {
        print(fromRect)
        let x = CGRectGetMinX(fromRect)
        let y = CGRectGetMaxY(fromRect)
        
        SJPopMenu.shareMenu.items = items
        
        view.addSubview(SJPopMenu.shareMenu)
        
        //let menu = SJPopMenu(frame: CGRectZero)
        //menu.items = items
        
        //UIApplication.sharedApplication().keyWindow?.addSubview(menu)
    }
    
    static func hideMenu(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = { [unowned self] in
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        t.layer.masksToBounds = true
        t.layer.cornerRadius = 5
        t.registerClass(SJPopItemCell.self, forCellReuseIdentifier: SJPopItemCell.reuseIdentifier)
        return t
    }()
    
    var titleFont: UIFont = UIFont.systemFontOfSize(14)
    var titleColor: UIColor = UIColor.whiteColor()
    
    func setupUI() {
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = [
            "tableView": tableView
        ]
        
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[tableView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(h)
        NSLayoutConstraint.activateConstraints(v)
    }
    
    override func drawRect(rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColor(c, CGColorGetComponents(UIColor.sjTintColor().CGColor))
        
        CGContextBeginPath(c)
        CGContextMoveToPoint(c, 5, 5)
        CGContextAddLineToPoint(c, 7.5, 0)
        CGContextAddLineToPoint(c, 15, 5)
        CGContextClosePath(c)
        CGContextFillPath(c)
        //CGContextDrawPath(c, .Fill)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
}

extension SJPopMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SJPopItemCell", forIndexPath: indexPath) as! SJPopItemCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
