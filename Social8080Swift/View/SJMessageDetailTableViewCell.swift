//
//  SJMessageDetailTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/28.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJMessageDetailTableViewCell: UITableViewCell {

    private lazy var content : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGrayColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var talk : UILabel = {
        let l = UILabel()
        l.textColor = UIColor ( red: 0.1938, green: 0.5085, blue: 0.8523, alpha: 1.0 )
        l.font = defaultFont(14)
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
        selectionStyle = .None
        
        contentView.addSubview(content)
        contentView.addSubview(talk)
        contentView.addSubview(datetime)
        
        talk.snp_makeConstraints { (make) in
            make.top.equalTo(3)
            make.left.equalTo(18)
            make.width.equalTo(contentView).dividedBy(2)
            make.height.equalTo(20)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.right.equalTo(-18)
            make.top.equalTo(3)
            make.width.equalTo(contentView).dividedBy(2)
            make.height.equalTo(15)
        }
        
        content.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(contentView.snp_right).offset(-18)
            make.top.equalTo(talk.snp_bottom).offset(3)
        }
    }
    
    func configCell(item : SJMessageModel) {
        content.text = item.content
        talk.text = item.talk! + ":"
        datetime.text = item.datetime
        content.sizeToFit()
    }
    
    static func calculateCellHeight(item : SJMessageModel) -> CGFloat{
        var cellHeight : CGFloat = 3 + 20 + 3
        let contentHeight = CGFloat(item.content!.calculateLabelHeight(defaultFont(14), width: ScreenSize.SCREEN_WIDTH - 36))
        cellHeight = cellHeight + contentHeight
        cellHeight += 4
        return cellHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
