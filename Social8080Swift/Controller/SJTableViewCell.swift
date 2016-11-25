//
//  SJTableViewCell.swift
//  Social8080Swift
//
//  Created by sujian on 11/16/16.
//  Copyright © 2016 sujian. All rights reserved.
//

import UIKit

class SJTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 ).CGColor)
        CGContextFillRect(context, ccr(0, 0, ScreenSize.SCREEN_WIDTH, 15))
    }
}
