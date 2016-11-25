//
//  SJFavourTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/16/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJFavourTableViewCell: UITableViewCell {
    
    private lazy var title : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGrayColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var category : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Right
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var datetime : UILabel = {
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
        
        contentView.addSubview(category)
        contentView.addSubview(datetime)
        contentView.addSubview(title)
        
        category.snp_makeConstraints {  (make) in
            make.right.equalTo(-8)
            make.top.equalTo(18)
            make.width.equalTo(120)
            make.height.equalTo(14)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(18)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        title.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(category.snp_bottom).offset(3)
            make.height.equalTo(20)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        
    }
    
    func configCell(favour: SJFavourModel){
        category.text = favour.category
        datetime.text = favour.datetime
        title.text = favour.title
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 ).CGColor)
        CGContextFillRect(context, ccr(0, 0, ScreenSize.SCREEN_WIDTH, 15))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
