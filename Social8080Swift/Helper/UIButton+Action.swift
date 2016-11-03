//
//  UIButton+Action.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/3.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import UIKit
private var closureKey : Void?
typealias ActionClosure = @convention(block) () -> ()
extension UIButton{
    func handleControlEvent(event: UIControlEvents, closure: ActionClosure){
        let dealObject: AnyObject = unsafeBitCast(closure, AnyObject.self)
        objc_setAssociatedObject(self, &closureKey, dealObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(callActionClosure(_:)), forControlEvents: event)
    }
    
    func callActionClosure(btn: UIButton){
        let closureObject: AnyObject = objc_getAssociatedObject(self, &closureKey)
        let closure = unsafeBitCast(closureObject, ActionClosure.self)
        closure()
    }
}