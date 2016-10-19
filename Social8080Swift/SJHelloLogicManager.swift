//
//  SJHelloLogicManager.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import UIKit

class SJHelloLogicManager: NSObject {
    
    private let classViewModel: SJHelloViewModel
    
    override init() {
        self.classViewModel = SJHelloViewModel()
        super.init()
    }
    
}
