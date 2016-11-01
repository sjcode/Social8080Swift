//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
var array : [String] = []

array.append("hello")

func myfunction(closure : (String,Int)->String) -> Void{
    print(closure("A String for closure",34))
}

func myClosureFunction(aStr : String) -> String{
    return aStr + " and closure's string"
}

public enum XPathObject {
    case None
    case NodeSet(nodeset: Swift.String)
    case Bool(bool: Swift.Bool)
    case Number(num: Double)
    case String(text: Swift.String)
}

let obj = XPathObject.NodeSet(nodeset: "hello")
if case let XPathObject.NodeSet(nodeset) = obj{
    print("nodeset = \(nodeset)")
}

let session = NSURLSession()

let string = "大猫对我说"
if let range = string.rangeOfString("我对"){
    let startindex = range.endIndex
    let endindex = string.endIndex.advancedBy(-1)
    
    string[startindex..<endindex]
}

if let range = string.rangeOfString("对我说"){
    let startindex = string.startIndex
    let endindex = range.startIndex
    string[startindex..<endindex]
}

