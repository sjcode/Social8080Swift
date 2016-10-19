//
//  SJClient.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/17.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Alamofire
import Kanna


class SJClient: NSObject {
    let BASE_URL = "http://bbs.8080.net/"
    class var sharedInstance: SJClient {
        struct Singleton {
            static let instance = SJClient()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B508 Safari/9537.53"]
    }
    
    func getPostList(link : String, page : Int, completeHandle: (posts : [SJPostModel]) -> ()) {
        let url = BASE_URL + link
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
                                        let author = node.xpath("div[@class='bm_user']/a")[0].content
                                        let datetime = node.xpath("div[@class='bm_user']/em/font")[0].content
                                        post = SJPostModel()
                                        post!.author = author
                                        post!.datetime = NSDate.dateFromString(datetime!)
                                    }else{
                                        let content = node.xpath("div[@class='mes']")[0].content!.stringByRemovingWhitespaceAndNewlineCharacterSet
                                        post?.content = content
                                        dataList.append(post!)
                                    }
                                }
                                completeHandle(posts: dataList)
                            }
                        }
                    }
        }
    }
    
    internal func getThreadList( fid : Int, typeid : Int, page : Int, completeHandle: (threads : [SJThreadModel]) -> ()){
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
                                        "\\s+([0-9]{4}-[0-9]{1,2}-[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2})\\s+回(\\d?)",
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
}
