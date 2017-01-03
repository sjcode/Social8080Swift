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

typealias PopupAction = (thread: SJThreadModel, sender: UIButton) -> ()

class SJHomeTableViewCell: UITableViewCell {
    static let margin : CGFloat = 3
    private var thread: SJThreadModel?
    var popupMenu : PopupAction?
    private lazy var avatar : AnimatedImageView = {
        let v = AnimatedImageView()
        v.autoPlayAnimatedImage = false
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    lazy var title : UILabel = {
        let l = UILabel()
        l.layer.masksToBounds = true
        l.backgroundColor = UIColor.whiteColor()
        l.textColor = UIColor.darkGrayColor()
        l.font = defaultFont(14)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var author : UILabel = {
        let l = UILabel()
        l.layer.masksToBounds = true
        l.backgroundColor = UIColor.whiteColor()
        l.textColor = UIColor ( red: 0.1938, green: 0.5085, blue: 0.8523, alpha: 1.0 )
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var datetime : UILabel = {
        let l = UILabel()
        l.layer.masksToBounds = true
        l.backgroundColor = UIColor.whiteColor()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var reply : UILabel = {
        let l = UILabel()
        l.layer.masksToBounds = true
        l.backgroundColor = UIColor.whiteColor()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var popupButton : UIButton = {
        let b = UIButton(type: .Custom)
        b.setImage(UIImage(named: "icon_popup_button"), forState: .Normal)
        b.addTarget(self, action: #selector(handlePopupMenu(_:)), forControlEvents: .TouchUpInside)
        return b
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatar)
        contentView.addSubview(author)
        contentView.addSubview(datetime)
        contentView.addSubview(reply)
        contentView.addSubview(title)
        contentView.addSubview(popupButton)
        
        avatar.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(3)
            make.size.equalTo(ccs(30,30))
        }
        
        author.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(3)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        popupButton.snp_makeConstraints { (make) in
            make.right.equalTo(-5)
            make.top.equalTo(5)
        }
        
        datetime.snp_makeConstraints { (make) in
            make.left.equalTo(avatar.snp_right).offset(3)
            make.top.equalTo(author.snp_bottom).offset(1)
            make.height.equalTo(14)
            make.width.equalTo(150)
        }
        
        reply.snp_makeConstraints { [weak self] (make) in
            make.right.equalTo(self!.popupButton.snp_left).offset(-5)
            make.top.equalTo(3)
            make.height.equalTo(18)
            make.width.equalTo(80)
        }
        
        title.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView).offset(-8)
            make.top.equalTo(datetime.snp_bottom).offset(3)
            make.height.equalTo(20)
        }
    }
    
    func configCell(thread : SJThreadModel){
        self.thread = thread
        avatar.kf_setImageWithURL(NSURL.init(string: SJUserModel.getAvatarUrl(thread.uid!)),
                                     placeholderImage: UIImage.init(named: "noavatar"),
                                     optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                     progressBlock: nil,
                                     completionHandler: nil)
        author.text = thread.author
        title.text = thread.title
        datetime.text = thread.datetime
        reply.text = "回复 \(thread.reply)"
    }
    
    func handlePopupMenu(sender: UIButton) {
        if let block = popupMenu, let t = thread {
            block(thread: t, sender: sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
