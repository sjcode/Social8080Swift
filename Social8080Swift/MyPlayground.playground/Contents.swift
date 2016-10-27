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



