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
        Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = 5
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
                    if let
                        headerFields = response.response?.allHeaderFields as? [String: String],
                        URL = response.request?.URL {
                        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                        Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: URL, mainDocumentURL: nil)
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
                                if let
                                    headerFields = response.response?.allHeaderFields as? [String: String],
                                    URL = response.request?.URL {
                                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                                    Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: URL, mainDocumentURL: nil)
                                }
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
    
    func getPostList(link : String, page : Int, completeHandle: (title : String, posts : [SJPostModel]) -> ()) {
        var url = ""
        if page == 1{
            url = BASE_URL + link
        }else{
            url = BASE_URL + link + "&page=" + String(page)
        }
        var title : String?
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
                            
                            if let titleNode = bodyNode?.at_xpath("//div[@class='bm_h']/a"){
                                title = titleNode.content
                            }
                            
                            var dataList = [SJPostModel]()
                            if let nodes = bodyNode?.xpath("//div[@class='bm_c bm_c_bg' or @class='pbody' or @class='box pd2 mbn']"){
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
                                    }else if(node.className == "box pd2 mbn"){
                                        let replylink = node.at_xpath("a")?["href"]
                                        post!.replylink = replylink
                                        dataList.append(post!)
                                    }else{
                                        let messageNode = node.xpath("div/div")
                                        if case let XPathObject.NodeSet(nodeset) = messageNode{
                                            for (_, element) in nodeset.enumerate(){
                                                let ps = element.at_xpath("i")
                                                if let pstatus = ps{
                                                    post!.pstatus = pstatus.text
                                                }
                                                let qu = element.at_xpath("div")
                                                if let quote = qu{
                                                    post!.quote = quote.text
                                                }
                                                if ps != nil{
                                                    element.removeChild(element.at_xpath("i")!)
                                                }
                                                if qu != nil{
                                                    element.removeChild(element.at_xpath("div")!)
                                                }

                                                let content = element.content!.stringByReplacingOccurrencesOfString("<br>\r\n", withString: "\n")
                                                .stringByReplacingOccurrencesOfString("<br>", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                                                
                                                post!.content = content.isEmpty ? "[表情]" : content

                                                if case let XPathObject.NodeSet(anodes) = element.xpath("a"){
                                                    
                                                    for (_, ahref) in anodes.enumerate(){
                                                        if let originalurl = ahref["href"]{
                                                            if let imagenode = ahref.at_xpath("img"){
                                                                if let thumbnialurl = imagenode["src"]{
                                                                    var original : String?
                                                                    var thumbnail : String?
                                                                    if !originalurl.hasPrefix("http://"){
                                                                        original = "http://bbs.8080.net/" + originalurl
                                                                    }else{
                                                                        original = originalurl
                                                                    }
                                                                    
                                                                    if !thumbnialurl.hasPrefix("http://"){
                                                                        thumbnail = "http://bbs.8080.net/" + thumbnialurl
                                                                    }else{
                                                                        thumbnail = thumbnialurl
                                                                    }

                                                                    let image = SJImageItem(originalurl: original, thumbnailurl : thumbnail)
                                                                    post!.images?.append(image)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                completeHandle(title : title!, posts: dataList)
                            }
                        }
                    }else{
                        completeHandle(title : "", posts: [])
                    }
        }
    }
    
    func getThreadList( fid : Int, typeid : Int, page : Int, completeHandle: (finish : Bool, threads : [SJThreadModel]) -> ()){
        var url = ""
        if typeid == -1{
            url = BASE_URL + "forum.php?mod=forumdisplay&fid="+String(fid)+"&mobile=yes&page=" + String(page)
        }else{
            url = BASE_URL + "forum.php?mod=forumdisplay&fid="+String(fid)+"&filter=typeid&typeid="+String(typeid)+"&mobile=yes&page=" + String(page)
        }
        Alamofire.request(.GET, url)
                 .responseData { (response) in
                    guard response.result.isSuccess else{
                        completeHandle(finish: false, threads: [])
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
                                completeHandle(finish: true, threads: dataList)
                            }
                        }
                        
                    }
        }
    }
    
    func sendPost(content : String, tid : Int, completed:(finish : Bool)->()){
        let url = BASE_URL + "forum.php?mod=post&action=reply&tid="+String(tid)+"&extra=&replysubmit=yes&mobile=yes"
        let params = ["formhash": formhash!,
                      "message":content,
                      "replaysubmit":"回复"]
        Alamofire.request(.POST, url, parameters : params ).responseData { ( response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false)
                return
            }
            
            if response.result.value != nil{
                completed(finish: true)
            }else{
                completed(finish: false)
            }
        }
    }
    
    func getMessageList(page : Int, completed:(finish : Bool, messages : [SJMessageModel])->()){
        let url = "http://bbs.8080.net/home.php?mod=space&do=pm&mobile=yes&page=" + String(page)
        Alamofire.request(.GET, url).responseData { (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false, messages: [])
                return
            }
            if response.result.value != nil{
                let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                    let bodyNode = doc.body
                    if let inputNodes = bodyNode?.xpath("//div[@class='bm_c']"){
                        var datalist = [SJMessageModel]()
                        for node in inputNodes{
                            var message = SJMessageModel()
                            if let ahref = node.at_xpath("p/a"){
                                message.content = ahref.content
                                message.link = ahref["href"]
                            }
                            
                            if let spancontent = node.at_xpath("p/span[@class='xg1'][1]"){
                                message.talk = spancontent.content
                            }
                            
                            if let spandatetime = node.at_xpath("p/span[@class='xg1'][2]"){
                                message.datetime = spandatetime.content
                            }
                            datalist.append(message)
                        }
                        completed(finish: true, messages: datalist)
                    }
                }
            }
        }
    }
    
    func getMessageDetail(link : String, completed:(finish: Bool, messages :[SJMessageModel], reply : Any?)->()){
        let url = "http://bbs.8080.net/" + link
        Alamofire.request(.GET, url).responseData { (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false, messages: [], reply: nil)
                return
            }
            if response.result.value != nil{
                let content : NSString = NSString.init(data: response.data!, encoding: NSUTF8StringEncoding)!
                if let doc = Kanna.HTML(html : content as String, encoding : NSUTF8StringEncoding){
                    let bodyNode = doc.body
                    if let inputNode = bodyNode?.xpath("//div[@class='bm_c']"){
                        var datalist = [SJMessageModel]()
                        var reply : SJReplyModel?
                        if case let XPathObject.NodeSet(nodeset) = inputNode{
                            let count = nodeset.count
                            for (index,node) in nodeset.enumerate(){
                                if index != count-1{    //不是最后一条
                                    var message = SJMessageModel()
                                    if let nickname = node.at_xpath("a"){
                                        message.talk = nickname.content
                                    }
                                    if let datetime = node.at_xpath("span[@class='xg1']"){
                                        message.datetime = datetime.content
                                    }
                                    
                                    if let content = node.at_xpath("dd[@class='xs1']"){
                                        message.content = content.content
                                    }
                                    datalist.append(message)
                                }else{
                                    //取出回复链接
                                    var action : String?
                                    var formhash : String?
                                    var touid : String?
                                    if let formnode = node.at_xpath("form"){
                                        action = formnode["action"]
                                        if let input1node = formnode.at_xpath("input[1]"){
                                            formhash = input1node["value"]
                                        }
                                        
                                        if let input2node = formnode.at_xpath("input[2]"){
                                            touid = input2node["value"]
                                        }
                                        reply = SJReplyModel(action: action, formhash: formhash, touid: touid)
                                    }
                                }
                            }
                            completed(finish: true, messages: datalist, reply:  reply!)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    func sendMessage(reply : SJReplyModel, message : String, completed : (finish : Bool)->()){
        let url = BASE_URL + reply.action!
        let params = ["formhash": reply.formhash!,
                      "message":message,
                      "pmsubmit":"true",
                      "topmuid":reply.touid!]
        Alamofire.request(.POST, url, parameters : params ).responseData { ( response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false)
                return
            }
            
            if response.result.value != nil{
                completed(finish: true)
            }else{
                completed(finish: false)
            }
        }
    }
    
    func getNoticeList(type : SJNoticeType, page : Int, completed : (finish : Bool, notices : [SJMessageModel])->()){
        let url = "http://bbs.8080.net/home.php?mod=space&do=notice&mobile=yes" + (type == SJNoticeType.OldNotice ? "&&isread=1" : "") + "&page=" + String(page)
        Alamofire.request(.GET, url).responseString { (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false, notices : [])
                return
            }
            if let doc = Kanna.HTML(html : response.result.value! as String, encoding : NSUTF8StringEncoding){
                let bodyNode = doc.body
                if let inputNodes = bodyNode?.xpath("//div[@class='bm_c']"){
                    var datalist = [SJMessageModel]()
                    for node in inputNodes{
                        var message = SJMessageModel()
                        if let ahref = node.at_xpath("div/a[2]"){
                            message.content = ahref.content
                            message.link = ahref["href"]
                        }
                        
                        if let people = node.at_xpath("div/a[1]"){
                            message.talk = people.content
                        }
                        
                        if let datetime = node.at_xpath("div[2]"){
                            message.datetime = datetime.content
                        }
                        datalist.append(message)
                    }
                    completed(finish: true, notices: datalist)
                }
            }else{
                completed(finish: true, notices: [])
            }
        }
    }
    
    func getNewThreadForm(fid : Int, completed : (finish : Bool, result : SJNewThreadFormModel?) -> ()) {
        let url = "http://bbs.8080.net/forum.php?mod=post&action=newthread&fid=" + String(fid) + "&mobile=yes"
        Alamofire.request(.GET, url).responseString { (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false, result : nil)
                return
            }
            if let doc = Kanna.HTML(html : response.result.value! as String, encoding: NSUTF8StringEncoding){
                let bodyNode = doc.body
                if let formnode = bodyNode?.xpath("//form[@id='postform']"){
                    let node = formnode[0]
                    var model = SJNewThreadFormModel()
                    model.action = node["action"]
                    
                    let categorys = node.xpath("div/div/select[@name='typeid']/option")
                    if case let XPathObject.NodeSet(nodeset) = categorys{
                        for (_, element) in nodeset.enumerate(){
                            dprint("\(element.content) : \(element["value"])")
                            if element["value"] != "0"{
                                model.category.append(SJNewThreadFormModel.SJCategoryModel(name : element.content, value : element["value"]))
                            }
                        }
                    }
                    
                    let inputs = node.xpath("input")
                    if case let XPathObject.NodeSet(nodeset) = inputs{
                        for (_, element) in nodeset.enumerate(){
                            if element["name"] == "formhash"{
                                model.formhash = element["value"]
                            }
                            else if element["name"] == "posttime"{
                                model.posttime = element["value"]
                            }
                        }
                    }
                    
                    completed(finish: true, result: model)
                }else{
                    completed(finish: false, result: nil)
                }
            }else{
                completed(finish: false, result: nil)
            }
        }
    }
    
    func sendNewThread(content : String, fid : Int, model : SJNewThreadFormModel, completed : (finish : Bool) -> ()) {
        
    }
    
    func getReplyForm(link : String, completed : (finish : Bool, result : SJReplyFormModel?) -> ()){
        let url = "http://bbs.8080.net/" + link
        Alamofire.request(.GET, url).responseString { (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false, result : nil)
                return
            }
            
            if let doc = Kanna.HTML(html : response.result.value! as String, encoding: NSUTF8StringEncoding){
                let bodyNode = doc.body
                if let formnode = bodyNode?.xpath("//form[@id='postform']"){
                    let node = formnode[0]
                    var model = SJReplyFormModel()
                    model.action = node["action"]
                    let inputs = node.xpath("input")
                    if case let XPathObject.NodeSet(nodeset) = inputs{
                        for (_, element) in nodeset.enumerate(){
                            if element["name"] == "formhash"{
                                model.formhash = element["value"]
                            }
                            else if element["name"] == "posttime"{
                                model.posttime = element["value"]
                            }
                            else if element["name"] == "noticeauthor"{
                                model.noticeauthor = element["value"]
                            }
                            else if element["name"] == "noticetrimstr"{
                                model.noticetrimstr = element["value"]
                            }
                            else if element["name"] == "noticeauthormsg"{
                                model.noticeauthormsg = element["value"]
                            }
                            else if element["name"] == "reppid"{
                                model.reppid = element["value"]
                            }
                            else if element["name"] == "reppost"{
                                model.reppost = element["value"]
                            }
                        }
                    }
                    completed(finish: true, result: model)
                }else{
                    completed(finish: false, result: nil)
                }
            }
        }
    }
    
    func sendReply(content : String, replyform : SJReplyFormModel, completed : (finish : Bool) -> ()){
        let url = "http://bbs.8080.net/" + replyform.action!
        
        let params = ["formhash" : replyform.formhash!,
                      "posttime" : replyform.posttime!,
                      "noticeauthor" : replyform.noticeauthor!,
                      "noticeauthormsg" : replyform.noticeauthormsg!,
                      "noticetrimstr" : replyform.noticetrimstr!,
                      "reppid" : replyform.reppid!,
                      "reppost" : replyform.reppost!,
                      "message" : content,
                      "submit" : "回复"
        ]
        
        Alamofire.request(.POST, url, parameters: params).responseString{ (response) in
            guard response.result.isSuccess else{
                dprint("失败")
                completed(finish: false)
                return
            }
            
            if response.result.value != nil{
                completed(finish: true)
            }else{
                completed(finish: false)
            }
        }
    }
}

















