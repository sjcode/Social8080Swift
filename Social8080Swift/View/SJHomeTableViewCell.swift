//
//  SJHomeTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

struct SJMargin {
    static let CELL_MARGIN : CGFloat = 3
}

class SJHomeTableViewCell: UITableViewCell {
    static let margin : CGFloat = 3
    
    private lazy var avatar : UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    private lazy var title : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGrayColor()
        l.font = UIFont.systemFontOfSize(14)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
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
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var reply : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = UIFont.systemFontOfSize(10)
        l.textAlignment = .Right
        l.numberOfLines = 1
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatar)
        contentView.addSubview(author)
        contentView.addSubview(datetime)
        contentView.addSubview(reply)
        contentView.addSubview(title)
        
        avatar.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(3)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        author.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(3)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(author.snp_bottom).offset(1)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        reply.snp_makeConstraints { (make) in
            make.right.equalTo(-18)
            make.top.equalTo(3)
            make.height.equalTo(18)
            make.width.equalTo(80)
        }
        
        title.snp_makeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(contentView).offset(-18)
            make.top.equalTo(datetime.snp_bottom).offset(3)
            make.height.equalTo(20)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(item : SJThreadModel){
        avatar.kf_setImageWithURL(NSURL.init(string: getAvatarUrl(item.uid!)),
                                     placeholderImage: UIImage.init(named: "noavatar"),
                                     optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                     progressBlock: nil,
                                     completionHandler: nil)
        author.text = item.author
        title.text = item.title
        datetime.text = item.datetime?.stringFromDate
        reply.text = "回复 \(item.reply)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
