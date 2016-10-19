import Cocoa

var str = "Hello, playground"
print("\(str.characters.count)")

var s = "10"

let len = Int(s)!
print("\(len)")

class Foo{
    var name : String
    var age : Int = 0
    init(name: String, age : Int){
        self.name = name
        self.age = age
    }
    
    func kick(message : String,
              closure : () -> String) -> String {
        
        return "hello " + closure()
    }
}

var list = [Foo]()

let foo1 = Foo(name: "arthur", age: Int(rand()))
list.append(foo1)
let foo2 = Foo(name: "sqh", age: Int(rand()))
list.append(foo2)
let foo3 = Foo(name: "zy", age: Int(rand()))
list.append(foo3)

var list2 = [Foo]()
let foo4 = Foo(name: "山虎", age: Int(rand()))
list2.append(foo4)

list2.appendContentsOf(list)

let foon = Foo(name: "foo", age : 100)


print(foon.kick("hello") { [weak foon] () -> String in
    
    return String(foon?.age) + "world"
})

func future(a : Int, b : Int, max : () -> String) -> String {
    return max()
}

future(2, b: 3) { () -> String in
    return "outlook"
}

var array : [AnyObject] = {
    return ["a","b","c"]
}()

var newarry = NSArray(array: array)
for item in newarry{
    print(item)
}

var string : String?
string = "ddf"
if string != nil{
    print("newline = \(string!)")
}

enum Animal{
    case None
    case Dog
    case Duck
    case Monkey
}

let animal = Animal.None
if animal == Animal.None{
    print("cat")
}

//26/12/05_avatar_small.jpg
let uid = "262205"
let uniqueid = Int(uid)

let a = uniqueid!/10000
let sb : String = String(uniqueid!/100)













