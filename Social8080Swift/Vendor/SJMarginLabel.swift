//
//  SJMarginLabel.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/23.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJMarginLabel: UILabel {
    var contentInsets : UIEdgeInsets?
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, self.contentInsets!))
    }
}
