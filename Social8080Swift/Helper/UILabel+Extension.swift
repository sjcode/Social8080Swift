//
//  UILabel+Extension.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

extension UILabel{
    static func labelWithFont(font : UIFont, textColor : UIColor) -> UILabel{
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        return label
    }
}