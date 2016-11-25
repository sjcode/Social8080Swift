//
//  SJMessageTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/28.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJMessageTableViewCell: UITableViewCell {
    
    private lazy var content : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGrayColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var talk : UILabel = {
        let l = UILabel()
        l.textColor = UIColor ( red: 0.1938, green: 0.5085, blue: 0.8523, alpha: 1.0 )
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var datetime : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Right
        l.numberOfLines = 1
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
        
        contentView.addSubview(content)
        contentView.addSubview(talk)
        contentView.addSubview(datetime)
        
        talk.snp_makeConstraints { (make) in
            make.top.equalTo(3)
            make.left.equalTo(8)
            make.width.equalTo(contentView).dividedBy(2)
            make.height.equalTo(20)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.right.equalTo(-8)
            make.top.equalTo(3)
            make.width.equalTo(contentView).dividedBy(2)
            make.height.equalTo(15)
        }
        
        content.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView.snp_right).offset(-18)
            make.top.equalTo(talk.snp_bottom).offset(3)
        }
    }
    
    func configCell(item : Any) {
        if item is SJMessageModel{
            let message = item as! SJMessageModel
            content.text = message.content
            talk.text = message.talk
            datetime.text = message.datetime
        }else if item is SJNoticeModel{
            let notice = item as! SJNoticeModel
            content.text = notice.title
            talk.text = notice.talk
            datetime.text = notice.datetime
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
