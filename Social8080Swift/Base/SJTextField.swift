//
//  SJTextField.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/1.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJTextField: UITextField {
    //文字右边距空8个像素
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 8, 0)
    }
    //placeholder右边距空8个像素
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 8, 0)
    }
    //clear按钮向左移35
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(CGRectGetWidth(bounds) - 35, 0, 30, 30)
    }
}
