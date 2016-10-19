//
//  SJThreadTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJThreadTableViewCell: UITableViewCell {
    
    private lazy var avatar : UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 25
        return v
    }()
    
    private lazy var author : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var datetime : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Right
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var content : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Left
        l.numberOfLines = 0
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatar)
        contentView.addSubview(author)
        contentView.addSubview(content)
        contentView.addSubview(datetime)
        
        avatar.snp_makeConstraints { (make) in
            make.leading.equalTo(18)
            make.top.equalTo(3)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        author.snp_makeConstraints { (make) in
            make.leading.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(3)
            make.width.equalTo(150)
            make.height.equalTo(18)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.trailing.equalTo(-18)
            make.top.equalTo(3)
            make.width.equalTo(150)
            make.height.equalTo(18)
        }
        
        content.snp_makeConstraints { (make) in
            make.leading.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(author.snp_bottom).offset(3)
            make.trailing.equalTo(-3)
        }
        
        
        
        
        
    }
    
    func configCell(item : SJPostModel){
        content.text = item.content
        content.sizeToFit()
        author.text = item.author
        datetime.text = item.datetime?.stringFromDate
        //reply.text = "回复 \(item.reply)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
