//
//  SJSettingValueTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/24.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJSettingValueTableViewCell: UITableViewCell {
    
    lazy var title : UILabel = {
        let l = UILabel(frame: ccr(0, 0, 200, 30))
        l.textColor = UIColor.blackColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        return l
    }()
    
    lazy var value : UILabel = {
        let l = UILabel(frame: ccr(0, 0, 100, 30))
        l.textColor = UIColor.blackColor()
        l.font = defaultFont(14)
        l.textAlignment = .Right
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(title)
        title.snp_makeConstraints { [weak self] (make) in
            make.centerY.equalTo(self!.contentView)
            make.left.equalTo(20)
        }
        
        contentView.addSubview(value)
        value.snp_makeConstraints { [weak self] (make) in
            make.centerY.equalTo(self!.contentView)
            make.right.equalTo(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
