//
//  SJThreadTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import Kingfisher

class SJThreadTableViewCell: UITableViewCell {
    
    private lazy var avatar : UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
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
    
    private lazy var floor : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Right
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var datetime : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var content : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(14)
        l.textAlignment = .Left
        l.numberOfLines = 0
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        contentView.addSubview(avatar)
        contentView.addSubview(author)
        contentView.addSubview(floor)
        contentView.addSubview(content)
        contentView.addSubview(datetime)
        
        avatar.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(3)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        author.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(3)
            make.width.equalTo(150)
            make.height.equalTo(18)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(author.snp_bottom)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        floor.snp_makeConstraints { (make) in
            make.right.equalTo(-18)
            make.top.equalTo(3)
            make.height.equalTo(18)
            make.width.equalTo(80)
        }
        
        content.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(contentView).offset(-18)
            make.top.equalTo(datetime.snp_bottom).offset(3)
        }
    }
    
    func configCell(item : SJPostModel){
        avatar.kf_setImageWithURL(NSURL.init(string: getAvatarUrl(item.uid!)),
                                  placeholderImage: UIImage.init(named: "noavatar"),
                                  optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
        author.text = item.author
        datetime.text = item.datetime?.stringFromDate
        content.text = item.content
        floor.text = item.floor
    }
    
    static func calculateCellHeight(item : SJPostModel) -> CGFloat{
        var heightOfCell : CGFloat = 35+6+1
        let heightOfContent = item.content!.calculateLabelHeight(UIFont.systemFontOfSize(14), width: ScreenSize.SCREEN_WIDTH-36-6-30)
        heightOfCell += heightOfContent
        
        return heightOfCell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
