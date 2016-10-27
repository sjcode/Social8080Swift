//
//  SJClient.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Alamofire
import Kanna
//*[@id="postmessage_12137293"]/text()[1]
let kNotificationLoginSuccess = "kNotificationLoginSuccess"

class SJClient: NSObject {
    let BASE_URL = "http://bbs.8080.net/"
    class var sharedInstance: SJClient {
        struct Singleton {
            static let instance = SJClient()
        }
        return Singleton.instance
    }
    
    //login before
    var loginhash : String?
    var idhash : String?
    
    //login after
    var formhash : String?
    var logout : String?
    
    //account
    var uid : String = ""
    var nickname: String?
    
    override init() {
        super.init()
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B508 Safari/9537.53"]
    }
    
    func doLoginWithUsername(username : String, password: String, secode : String, completed:(finished : Bool, error : NSError?, uid : String?)->()){
        let url = "http://bbs.8080.net/member.php?mod=logging&action=login&loginsubmit=yes&loginhash="+self.loginhash!+"&mobile=yes"
        let params = [
            "formhash": self.formhash!,
            "referer":"http://bbs.8080.net/forum.php",
            "fastloginfield":"username",
            "username":username,
            "password":password,
            "sechash":self.idhash!,
            "seccodeverify":secode,
            "submit":"登陆",
            "questionid":"0",
            "answer":"",
            "cookietime":"2592000"
            ]
        Alamofire.request(.POST, url, parameters : params ).responseData { [weak self] ( response) in
            guard response.result.isSuccess else{
                completed(finished: false, error: response.result.error!, uid: nil)
                return
            }
            
            if response.result.value != nil{
                let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                if content.rangeOfString("欢迎您回来").location != NSNotFound{
                    if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                        let ahref = doc.xpath("//div[@class='pd2']/a")[0]
                        self!.uid = extractByRegex(ahref["href"]!, pattern: "uid=(\\d+)&do=profile&mobile=yes")
                    }
                    completed(finished: true, error : nil, uid: self!.uid)
                }else{
                    func makeerror(message : String) -> NSError{
                        let error = NSError(domain: "http://bbs.8080.net", code: 1, userInfo: ["message": message])
                        return error
                    }
                    
                    if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                        let message = doc.xpath("//div[@id='messagetext']/p")[0].content!
                        completed(finished: false, error: makeerror(message), uid: nil)
                        
                    }
                }
            }
        }
        
    }
    
    func tryLoginAndLoadUI(loadUI : Bool,completed: (finish : Bool, error : NSError?, uid : String?)->()){
        let url = "http://bbs.8080.net/member.php?mod=logging&action=login&mobile=yes"
        Alamofire.request(.GET, url)
                 .responseData{[weak self](response) in
                    guard response.result.isSuccess else{
                    dprint("失败")
                    return
                 }
                    if response.result.value != nil{
                        let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                        if content.rangeOfString("欢迎您回来").location != NSNotFound{
                            if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                                let ahref = doc.xpath("//div[@class='pd2']/a")[0]
                                self?.uid = extractByRegex(ahref["href"]!, pattern: "uid=(\\d+)&do=profile&mobile=yes")
                                self?.nickname = (ahref.content?.stringByRemovingWhitespaceAndNewlineCharacterSet)!
                                
                                self?.logout = doc.xpath("//a[@class='exit']")[0]["href"]
                                self?.formhash = extractByRegex((self?.logout!)!, pattern: "formhash=(\\w+)&mobile=yes")
                                completed(finish: true, error: nil , uid : self?.uid)
                            }
                        }else{
                            if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                                let formnode = doc.xpath("//form")[0]
                                let action = formnode["action"]!
                                
                                self!.loginhash = extractByRegex(action, pattern: "loginsubmit=yes&loginhash=(.*?)&mobile=yes")
                                self!.formhash = doc.xpath("//form/input[@name='formhash']")[0]["value"]!
                                let imageurl = doc.xpath("//img")[1]["src"]!
                                self!.idhash = extractByRegex(imageurl, pattern: "&idhash=(.*?)&mobile=yes")
                                
                                if loadUI{
                                    self!.downloadSecodeImage(self!.idhash!, completed: { (imagefile) in
                                        if imagefile.characters.count > 0{
                                            completed(finish: true, error:nil, uid : nil )
                                        }
                                    })
                                }else{
                                    completed(finish: true, error:nil, uid : nil )
                                }
                            }
                        }
                    }
        }
    }
    
    func downloadSecodeImage(idhash : String, completed : (imagefile : String)->()){
        let url = "http://bbs.8080.net/misc.php?mod=seccode&action=update&idhash="+idhash+"&inajax=1&ajaxtarget=seccode_"+idhash
        Alamofire.request(.GET, url).responseData {(response) in
            guard response.result.isSuccess else{
                dprint("失败")
                return
            }
            if response.result.value != nil{
                let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                let src = "http://bbs.8080.net/"+extractByRegex(content as String, pattern: "src=\"(.*?)\" class=")
                
                let headers = [
                    "Referer": "http://bbs.8080.net/member.php?mod=logging&action=login",
                ]
                
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(dp("seccode.gif"))
                }catch _{
                    dprint("not found secode.gif")
                }
                
                let destination : Alamofire.Request.DownloadFileDestination = {_, response in
                    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    let pathComponent = "seccode.gif"
                    
                    let localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
                    return localPath
                }
                
                Alamofire.download(.GET, src, headers : headers, destination: destination)
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        print(totalBytesRead)
                    }
                    .response { request, response, _, error in
                        print(response)
                        completed(imagefile: "ok")
                    
                }
            }
        }
    }
    
    func getPostList(link : String, page : Int, completeHandle: (posts : [SJPostModel]) -> ()) {
        var url = ""
        if page == 1{
            url = BASE_URL + link
        }else{
            url = BASE_URL + link + "&page=" + String(page)
        }
        Alamofire.request(.GET, url)
                .responseData{ (response) in
                guard response.result.isSuccess else{
                    dprint("失败")
                    return
                }
                    if response.result.value != nil{
                        let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                        if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                            let bodyNode = doc.body
                            
                            var dataList = [SJPostModel]()
                            if let nodes = bodyNode?.xpath("//div[@class='bm_c bm_c_bg' or @class='pbody']"){
                                var post : SJPostModel?
                                for node in nodes{
                                    if node.className == "bm_c bm_c_bg"{
                                        let floornode = node.xpath("div[@class='bm_user']")[0].content!
                                        let array = floornode.componentsSeparatedByString("\t")
                                        let floor = array[1].stringByRemovingWhitespaceAndNewlineCharacterSet
                                        
                                        let usernode = node.xpath("div[@class='bm_user']/a")[0]
                                        let uid = extractByRegex(usernode["href"]!, pattern: "uid=(\\d+)&mobile=yes")
                                        let author = usernode.content
                                        let datetime = node.xpath("div[@class='bm_user']/em/font")[0].content
                                        
                                        post = SJPostModel()
                                        post!.uid = uid
                                        post!.floor = floor
                                        post!.postid = node["id"]
                                        post!.author = author
                                        post!.datetime = NSDate.dateFromString(datetime!)
                                    }else{
                                        let messageNode = node.xpath("div/div")
                                        if case let XPathObject.NodeSet(nodeset) = messageNode{
                                            for (_, element) in nodeset.enumerate(){
                                                if let pstatus = element.at_xpath("i"){
                                                    post!.pstatus = pstatus.text
                                                }
                                                if let quote = element.at_xpath("div"){
                                                    post!.quote = quote.text
                                                }
                                                if case let XPathObject.NodeSet(nodeset) = element.xpath("text()"){
                                                    var contents = ""
                                                    for (_, content) in nodeset.enumerate(){
                                                        if let value = content.text{
                                                            contents.appendContentsOf(value)
                                                        }
                                                    }
                                                    post!.content = contents.stringByRemovingWhitespaceAndNewlineCharacterSet
                                                }
                                                if case let XPathObject.NodeSet(anodes) = element.xpath("a"){
                                                    
                                                    for (_, ahref) in anodes.enumerate(){
                                                        if let originalurl = ahref["href"]{
                                                            if let imagenode = ahref.at_xpath("img"){
                                                                if let thumbnialurl = imagenode["src"]{
                                                                    let image = SJImageItem(originalurl: originalurl, thumbnailurl: thumbnialurl)
                                                                    post!.images?.append(image)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        dataList.append(post!)
                                    }
                                }
                                completeHandle(posts: dataList)
                            }
                        }
                    }else{
                        completeHandle(posts: [])
                    }
        }
    }
    
    func getThreadList( fid : Int, typeid : Int, page : Int, completeHandle: (threads : [SJThreadModel]) -> ()){
        var url = ""
        if typeid == -1{
            url = BASE_URL + "forum.php?mod=forumdisplay&fid="+String(fid)+"&mobile=yes&page=" + String(page)
        }else{
            url = BASE_URL + "forum.php?mod=forumdisplay&fid="+String(fid)+"&filter=typeid&typeid="+String(typeid)+"&mobile=yes&page=" + String(page)
        }
        Alamofire.request(.GET, url)
                 .responseData { (response) in
                    guard response.result.isSuccess else{
                        dprint("失败")
                        return
                    }
                    if response.result.value != nil{
                        let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                        if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                            let bodyNode = doc.body
                            var dataList = [SJThreadModel]()
                            if let inputNodes = bodyNode?.xpath("//div[@class='bm_c' or @class='bm_c bt']") {
                                for node in inputNodes {
                                    let href = node.xpath("a")[0]
                                    let link = href["href"]
                                    let title = href.content!.stringByRemovingWhitespaceAndNewlineCharacterSet
                                    let userNode = node.xpath("span/a")[0]
                                    let author = userNode.content!.stringByRemovingWhitespaceAndNewlineCharacterSet
                                    
                                    let uid = extractByRegex(userNode["href"]!, pattern: "uid=(\\d+)&mobile=yes")
                                    
                                    let writedate = node.xpath("span")[0].content!.stringByReplacingOccurrencesOfString("\r\n", withString: " ")
                                    
                                    let regex = try! NSRegularExpression(pattern:
                                        "\\s+([0-9]{4}-[0-9]{1,2}-[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2})\\s+回(\\d+)",
                                        options: .CaseInsensitive)
                                    
                                    let results = regex.matchesInString(writedate, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, writedate.characters.count))
                                    
                                    if results.count == 1{
                                        let match = results[0]
                                        
                                        let range1 = match.rangeAtIndex(1)
                                        let range2 = match.rangeAtIndex(2)
                                        
                                        let datetimestring = writedate[range1]
                                        
                                        let reply = Int(writedate[range2])!
                                        
                                        let dateFormatter = NSDateFormatter()
                                        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
                                        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm")
                                        let datetime = dateFormatter.dateFromString(datetimestring)
                                        let thread = SJThreadModel(title: title, link: link!, datetime: datetime!, reply: reply, author: author, uid: uid)
                                        dataList.append(thread)
                                    }
                                }
                                completeHandle(threads: dataList)
                            }
                        }
                        
                    }
        }
    }
    
    func sendPost(content : String, fid : Int, tid : Int, completed:()->()){
        let url = BASE_URL + "forum.php?mod=post&action=reply&fid="+String(fid)+"&tid="+String(tid)+"&extra=&replysubmit=yes&mobile=yes"
        let params = ["formhash": formhash!,
                      "message":content,
                      "replaysubmit":"回复"]
        Alamofire.request(.POST, url, parameters : params ).responseData { ( response) in
            guard response.result.isSuccess else{
                dprint("失败")
                return
            }
            
            if response.result.value != nil{
                //let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                completed()
            }else{
            
            }
        }
    }
}

















