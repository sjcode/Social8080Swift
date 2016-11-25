//
//  Model.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation

struct SJUserModel{

    
    //account
    var uid : String?{
        didSet{
            smallavatarurl = SJUserModel.getAvatarUrl(uid!)
            middleavatarurl = SJUserModel.getMiddleAvatarUrl(uid!)
            bigavatarurl = SJUserModel.getBigAvatarUrl(uid!)
        }
    }
    var nickname: String?
    
    //login after
    var formhash : String?
    var logout : String?
    
    var smallavatarurl : String!
    var middleavatarurl : String!
    var bigavatarurl : String!
    
    static func getAvatarUrl(uid : String) -> String{
        let uid = Int(uid)!
        
        let a = uid/10000%10000
        let b = uid/100%100
        let c = uid%100
        return String(format: "http://bbs.8080.net/uc_server/data/avatar/000/%02d/%02d/%02d_avatar_small.jpg",a,b,c)
    }
    
    static func getMiddleAvatarUrl(uid : String) -> String{
        let uid = Int(uid)!
        
        let a = uid/10000%10000
        let b = uid/100%100
        let c = uid%100
        return String(format: "http://bbs.8080.net/uc_server/data/avatar/000/%02d/%02d/%02d_avatar_middle.jpg",a,b,c)
    }
    
    static func getBigAvatarUrl(uid : String) -> String{
        let uid = Int(uid)!
        
        let a = uid/10000%10000
        let b = uid/100%100
        let c = uid%100
        return String(format: "http://bbs.8080.net/uc_server/data/avatar/000/%02d/%02d/%02d_avatar_big.jpg",a,b,c)
    }
}

struct SJThreadModel {
    var link : String?{
        didSet{
            tid = extractByRegex(link!, pattern : "forum.php\\?mod=viewthread&tid=(\\d+)&mobile=yes")
            if tid == nil{//如果不是从home过来的, 那就一定是从message过来的
                tid = extractByRegex(link!, pattern : "forum.php\\?mod=redirect&goto=findpost&ptid=(\\d+)&pid=")
            }
        }
    }
    var title : String?
    var datetime : String?
    var reply : Int = 0
    var author : String?
    var uid : String?
    var tid : String?
}

struct SJFavourModel {
    var title : String?
    var link : String?
    var datetime : String?
    var dellink : String?
    var category : String?
}

struct SJPostModel {
    var uid : String?
    var author : String?
    var datetime : NSDate?
    var content : String?
    var postid : String?
    var replylink : String?
    var floor : String?
    var pstatus : String?
    var quote : String?
    var images : [SJImageItem]?
    init(){
        images = []
    }
}

struct SJSecCodeModel{
    var secvalue : String?
    var secimage : String?
    var seccode : String?
}

struct SJImageItem {
    var originalurl : String?
    var thumbnailurl : String?
}

struct SJMessageModel{
    var content : String?
    var link : String?
    var talk : String?
    var datetime : String?
}

struct SJNoticeModel{
    var title: String?
    var datetime: String?
    var link: String?
    var talk: String?
    var uid: String?
    var tid: String?
}

struct SJReplyModel{
    var action : String?
    var formhash : String?
    var touid : String?
}

struct SJReplyFormModel {
    var action : String?
    var formhash : String?
    var posttime : String?
    var noticeauthor : String?
    var noticetrimstr : String?
    var noticeauthormsg : String?
    var reppid : String?
    var reppost : String?
}

struct SJNewThreadFormModel{
    struct SJCategoryModel{
        var name : String?
        var value : String?
    }
    var fid :  String?
    var action : String?
    var formhash : String?
    var posttime : String?
    var category = [SJCategoryModel]()
    
}

class Foo{
    
}

enum SJProfileState {
    case Online,Offline
}
enum SJProfileKey{
    case Message, Notice, Footer, MyThreads, Favour
}

class SJProfileMenuItem{
    init(key: SJProfileKey, icon: String, title: String, state: SJProfileState, controller: String){
        self.key = key
        self.icon = icon
        self.title = title
        self.state = state
        self.controller = controller
    }
    var key: SJProfileKey
    var icon: String
    var title: String
    var state: SJProfileState
    var controller: String
}












