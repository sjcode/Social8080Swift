//
//  SJProfileTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

typealias ClickProfileButton = (item : SJProfileMenuItem) -> ()

class SJProfileTableViewCell: UITableViewCell {
    lazy var icon : UIImageView = {
        let v = UIImageView(frame: ccr(0, 0, 25, 25))
        v.contentMode = .ScaleToFill
        return v
    }()
    
    lazy var title : UILabel = {
        let l = UILabel(frame: ccr(0, 0, 70, 30))
        l.textColor = UIColor.blackColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        return l
    }()
    
    private lazy var btn : UIButton = {
        let b = UIButton(type: .System)
        b.setTitle("测试按钮", forState: .Normal)
        b.setTitleColor(UIColor.grayColor(), forState: .Normal)
        b.titleLabel?.font = defaultFont(12)
        b.addTarget(self, action: #selector(clickBtn(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    var tapHandle : ClickProfileButton?
    
    var item : SJProfileMenuItem!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(icon)
        icon.snp_makeConstraints { [weak self](make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(15)
        }
        
        contentView.addSubview(title)
        title.snp_makeConstraints { [weak self](make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(self!.icon.snp_right).offset(10)
        }
        
//        contentView.addSubview(btn)
//        btn.snp_makeConstraints { [weak self] (make) in
//            make.centerY.equalTo(self!.contentView)
//            make.left.equalTo(self!.title.snp_right).offset(20)
//        }
    }
    
    func configCell(item: SJProfileMenuItem){
        self.item = item
        title.text = item.title
        icon.image = UIImage(named: item.icon)?.imageWithRenderingMode(.AlwaysTemplate)
        if item.state == .Offline{
            title.textColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
            icon.tintColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        }else{
            title.textColor = UIColor.blackColor()
            icon.tintColor = UIColor.blackColor()
        }
    }
    
    func clickBtn(sender : UIButton){
        if let block = tapHandle{
            block(item: item)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
