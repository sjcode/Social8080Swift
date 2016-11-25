//
//  SJMyThreadsTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/18/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJMyThreadsTableViewCell: SJTableViewCell {

    private lazy var title : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGrayColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var reply : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        contentView.addSubview(reply)
        contentView.addSubview(title)
        
        reply.snp_makeConstraints {  (make) in
            make.left.equalTo(8)
            make.top.equalTo(18)
            make.width.equalTo(120)
            make.height.equalTo(14)
        }
        
        title.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(reply.snp_bottom).offset(3)
            make.height.equalTo(20)
        }
        
    }
    
    func configCell(thread: SJThreadModel){
        reply.text = "回" + String(thread.reply)
        title.text = thread.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
