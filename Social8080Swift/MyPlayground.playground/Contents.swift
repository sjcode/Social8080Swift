//: Playground - noun: a place where people can play

import Cocoa

var str = "回1"
var array : [String] = []

array.append("hello")

let a1 : [Dictionary<String, String>] = [["name":"aaaa"],["name":"bug"]]


var datetime : String!
var reply : String!
if let range = str.rangeOfString("回"){
    //datetime = str.substringToIndex(range.startIndex.advancedBy(-1))
    reply = str.substringFromIndex(range.startIndex.advancedBy(1))
    //print(datetime)
    print(reply)
}else{
    let result = str
    print(result)
}



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

let string = "大猫我对说"
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

class Base{
    init(string : String){
        print("base init")
    }
}

class Foo : Base{
    override init(string : String){
        super.init(string: string)
        print("Foo init")
    }
}

extension String {
    var stringByRemovingWhitespaceAndNewlineCharacterSet: String {
        return componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).joinWithSeparator("")
    }
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex)
            
            return self[startIndex..<endIndex]
        }
    }
    
    subscript(r : NSRange) -> String{
        get{
            return (self as NSString).substringWithRange(r)
        }
    }
}

let foo = Foo(string: "hello")

let content = "<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">  今天继续写我眼中最无前景的十个城市第四部分，最后有三个城市雀屏中选。</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">     强调一下筛选标准，首先是人口流失的地级及地级以上城市，这些城市在此前三十年以制造业发展为主体的工业化改革中，作为劳动力的输出地，人口源源不断地流出本地。目前面临经济转型期，人口仍在源源不断地流出，有想法、有实力的人率先出走，给当地留下一地鸡毛</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">    其次是一个城市只有几个国企主导的行业，并且大企业办社会，使得城市服务业无法细分，导致当地市场意识落后，父母热衷于逼迫子女考公务员、进入国有大中型企业，从进入的第一天就可以看到退休的那一天。</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">    第三是人均财富占有量低，教育相对不发达，相应的，消费数据也较低，基本上啃玉米穿着花哨衣服的人比较多。</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">    除此之外，还包含了我对当地城市未来发展的预期，我在各地看到的消费能力低、市场弹性差的地方，这一部分源自我在各地的实地感受，比较有弹性。</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">    我只列上我验证后有说服力的指标，其他指标就不罗列了，这些指标或者容易掺水，或者无法反映城市未来预期，我认为说服力不强。另外，地级以下的城市就不写了，除添堵之外没有其他好处。</font></font></font></p>\n<p style=\"line-height:25px;text-indent:nullem;text-align:left\"><font color=\"#333333\"><font style=\"background-color:rgb(240, 245, 245)\"><font face=\"Simsun\">   此次选择的这些城市有可能一度发展比较快，受制于文化、制度以及当地的产业，现在却露出后劲不足的疲惫之态。</font></font></font></p>\n\n<font color=\"#404040\">叶檀个人列出的“最无前途的中国十个城市”榜单上包含<strong>长春、哈尔滨、沈阳、兰州、大同、洛阳、南昌、温州、唐山、大连</strong>10座城市。她在《我眼中最无前途的中国十个城市（终）》一文中表示，也有其他侯选城市，比如安徽淮南、湖南株洲等地，但“考虑到典型性，选取了上述城市”。</font>\n\n文章一出，带一些市的居民，领导肺都气炸了。。。。经济学家敢说，就是厉害的。"


do{
    let regex = try NSRegularExpression(pattern: "<(\\S*?)[^>]*>", options: .CaseInsensitive)
    content[0..<10]
    let results = regex.matchesInString(content, options: .ReportProgress, range: NSMakeRange(0, content.characters.count))
    if results.count == 1{
        let match = results[0]
        let range1 = match.rangeAtIndex(1)
        let range2 = match.rangeAtIndex(2)
        
        let datetimestring = content[range1]
    }
    
}catch{
    
}

//










