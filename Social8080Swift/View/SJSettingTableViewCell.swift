//
//  SJSettingTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/8/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJSettingTableViewCell: UITableViewCell {
    
    lazy var icon : UIImageView = {
        let v = UIImageView(frame: ccr(0, 0, 30, 30))
        v.contentMode = .ScaleToFill
        return v
    }()
    
    lazy var title : UILabel = {
        let l = UILabel(frame: ccr(0, 0, 200, 30))
        l.textColor = UIColor.blackColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(icon)
        icon.snp_makeConstraints { [weak self](make) in
            make.centerY.equalTo(self!.contentView)
            make.size.equalTo(ccs(30, 30))
            make.left.equalTo(8)
        }
        
        contentView.addSubview(title)
        title.snp_makeConstraints { [weak self](make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(self!.icon.snp_right).offset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
