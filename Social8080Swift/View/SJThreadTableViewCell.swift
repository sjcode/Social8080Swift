//
//  SJThreadTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit
import Kingfisher

let MAX_LINE_ROW : Int = 3
let PICTURE_SPACING : Int = 3

class SJThreadTableViewCell: UITableViewCell {
    
    private lazy var avatar : AnimatedImageView = {
        let v = AnimatedImageView()
        v.autoPlayAnimatedImage = false
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    private lazy var author : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(10)
        l.textAlignment = .Left
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var floor : UILabel = {
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
    
    private lazy var pstatus : UILabel = {
        let l = UILabel()
        l.textColor = UIColor ( red: 0.1264, green: 0.1264, blue: 0.1264, alpha: 1.0 )
        l.font = defaultFont(12)
        l.textAlignment = .Left
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var quote : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.grayColor()
        l.backgroundColor = UIColor ( red: 0.9729, green: 0.9776, blue: 0.7053, alpha: 1.0 )
        l.layer.borderColor = UIColor ( red: 1.0, green: 0.9031, blue: 0.3408, alpha: 1.0 ).CGColor
        l.font = defaultFont(12)
        l.textAlignment = .Left
        l.numberOfLines = 0
        return l
    }()
    
    lazy var content : UITextView = {
        let l = UITextView()
        l.showsVerticalScrollIndicator = false
        l.showsHorizontalScrollIndicator = false
        l.textContainerInset = UIEdgeInsetsMake(-3, -5, -3, -5)
        l.scrollEnabled = false
        l.dataDetectorTypes = [.Link]
        l.editable = false
        l.selectable = true
        l.textColor = UIColor.grayColor()
        l.font = defaultFont(16)
        l.textAlignment = .Left
        return l
    }()
    
    private lazy var imagegrid : UIView = { [unowned self] in
        let v = UIView()
        v.addGestureRecognizer(self.tapimage)
        return v
    }()
    
    lazy var tapimage : UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        return tap
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        contentView.addSubview(avatar)
        contentView.addSubview(author)
        contentView.addSubview(floor)
        contentView.addSubview(pstatus)
        contentView.addSubview(quote)
        contentView.addSubview(content)
        contentView.addSubview(imagegrid)
        contentView.addSubview(datetime)
        
        avatar.snp_makeConstraints { (make) in
            make.left.equalTo(8)
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
            make.right.equalTo(-8)
            make.top.equalTo(3)
            make.height.equalTo(18)
            make.width.equalTo(80)
        }
        
        pstatus.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView).offset(-8)
            make.top.equalTo(datetime.snp_bottom).offset(3)
        }
        
        quote.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView).offset(-8)
            make.top.equalTo(pstatus.snp_bottom).offset(3)
        }
 
        content.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView).offset(-8)
            make.top.equalTo(quote.snp_bottom).offset(3)
        }
        
        imagegrid.snp_makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(contentView).offset(-8)
            make.top.equalTo(content.snp_bottom).offset(3)
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
        floor.text = item.floor
        pstatus.text = item.pstatus
        quote.text = item.quote
        
        
        let contentHeight = item.content?.calculateLabelHeight(defaultFont(16), width: ScreenSize.SCREEN_WIDTH - 16)
        dprint("height = \(contentHeight) content = \(item.content)")
        content.snp_updateConstraints { (make) in
            make.height.equalTo(contentHeight! + 2)
        }
        
        content.text = item.content
    
        let imagegridsize = CGSizeMake(ScreenSize.SCREEN_WIDTH - 16, CGFloat.max)
        
        let imageWidth = (imagegridsize.width - 6) / 3
        let imageHeight = imageWidth
        
        if item.images?.count > 0 {
        
            let line = ((item.images?.count)! / 3) + ((item.images?.count)! % 3 == 0 ? 0 : 1)
            
            let gridviewHeight = (imageHeight * CGFloat(line)) + 6
            
            var x : CGFloat = 0.0
            var y : CGFloat = 0.0
            
            for (i, image) in (item.images?.enumerate())! {
                let m = i / MAX_LINE_ROW
                if m == 0{
                    let j : CGFloat = CGFloat(i % MAX_LINE_ROW)
                    x = imageWidth * j + (j == 0 ? 0 : j * CGFloat(PICTURE_SPACING))
                    y = 0
                }else{
                    let j : CGFloat = CGFloat(i % MAX_LINE_ROW)
                    x = imageWidth * j + (j == 0 ? 0 : j * CGFloat(PICTURE_SPACING))
                    y = CGFloat(m) * imageHeight + (CGFloat(m) * CGFloat(PICTURE_SPACING))
                }
                
                let imageView = UIImageView(frame: CGRectMake(x, y, imageWidth, imageHeight))
                imageView.backgroundColor = UIColor(hexString: "#E8ECEE")
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.kf_setImageWithURL(NSURL.init(string: image.thumbnailurl!),
                                          placeholderImage: UIImage.init(named: "bk_pic_placeholder"),
                                          optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                          progressBlock: nil,
                                          completionHandler: nil)
                imagegrid.addSubview(imageView)
            }
            imagegrid.snp_updateConstraints { (make) in
                make.size.equalTo(CGSizeMake(imagegridsize.width, gridviewHeight))
            }
            imagegrid.hidden = false
        }else{
            imagegrid.hidden = true
        }
    }
    
    static func calculateCellHeight(item : SJPostModel) -> CGFloat{
        var heightOfCell : CGFloat = 3 + 30 + 3//35+6+1
        
        if let pstats = item.pstatus{
            heightOfCell += pstats.calculateLabelHeight(defaultFont(14), width: ScreenSize.SCREEN_WIDTH-16)
            
        }
        heightOfCell += 3
        
        if let quote = item.quote{
            heightOfCell += quote.calculateLabelHeight(defaultFont(12), width: ScreenSize.SCREEN_WIDTH-16)
        }
        heightOfCell += 3
        
        if let content = item.content{
            heightOfCell += content.calculateLabelHeight(defaultFont(16), width: ScreenSize.SCREEN_WIDTH-16)
        }
        heightOfCell += 3
        
        if item.images?.count > 0{
            let images = item.images
            let size = eachImageSize()
            let line = (images!.count / 3) + (images!.count % 3 == 0 ? 0 : 1)
            let gridviewHeight = (size.height * CGFloat(line)) + CGFloat((line - 1) * 3)
            
            heightOfCell += gridviewHeight
        }
        heightOfCell += 3
        
        return heightOfCell
    }
    
    func setContentDelegate(delegate : protocol<UITextViewDelegate>, index : Int){
        content.delegate = delegate
        objc_setAssociatedObject(content, &closureKey, index, .OBJC_ASSOCIATION_ASSIGN)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func eachImageSize() -> CGSize{
    let imagegridwidth = ScreenSize.SCREEN_WIDTH - 16
    let imageWidth = (imagegridwidth - 6) / 3
    let imageHeight = imageWidth
    
    return CGSizeMake(imageWidth, imageHeight)
}

private var closureKey: Void?
