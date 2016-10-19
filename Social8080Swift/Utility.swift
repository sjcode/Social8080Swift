//
//  Utility.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/19.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation

func extractByRegex(string : String, pattern : String) -> String{
    let regex = try! NSRegularExpression(pattern:pattern,options: .CaseInsensitive)
    
    let results = regex.matchesInString(string, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, string.characters.count))
    
    if results.count == 1{
        let match = results[0]
        let range1 = match.rangeAtIndex(1)
        return string[range1]
    }
    
    return ""
}