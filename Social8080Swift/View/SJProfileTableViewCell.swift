//
//  SJProfileTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/9/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJProfileTableViewCell: UITableViewCell {
    lazy var icon : UIImageView = {
        let v = UIImageView(frame: ccr(0, 0, 25, 25))
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
            make.left.equalTo(15)
        }
        
        contentView.addSubview(title)
        title.snp_makeConstraints { [weak self](make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(self!.icon.snp_right).offset(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
