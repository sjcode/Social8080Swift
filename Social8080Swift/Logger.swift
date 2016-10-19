//
//  Logger.swift
//  QuanDiSwift
//
//  Created by sujian on 16/7/16.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation

func dprint(@autoclosure item : () -> Any){
    #if DEBUG
        print(item())
    #endif
}
