//
//  View+Extension.swift
//  Social8080Swift
//
//  Created by sujian on 16/11/3.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation
import UIKit
private var closureKey : Void?
typealias tapClosure = @convention(block) (gesture : UITapGestureRecognizer) -> ()
extension UIView{
    func addTapEventHandle(closure : tapClosure){
        let dealObject : AnyObject = unsafeBitCast(closure, AnyObject.self)
        objc_setAssociatedObject(self, &closureKey, dealObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        let tap = UITapGestureRecognizer(target: self, action: #selector(callGestureClosure(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func callGestureClosure(gesture : UITapGestureRecognizer){
        let closureObject : AnyObject = objc_getAssociatedObject(self, &closureKey)
        let closure = unsafeBitCast(closureObject, tapClosure.self)
        closure(gesture: gesture)
    }
}