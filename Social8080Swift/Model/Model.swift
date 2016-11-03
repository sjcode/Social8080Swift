//
//  Model.swift
//  Social8080Swift
//
//  Created by sujian on 16/10/18.
//  Copyright © 2016年 sujian. All rights reserved.
//

import Foundation

struct SJThreadModel {
    var title : String?
    var link : String?
    var datetime : NSDate?
    var reply : Int = 0
    var author : String?
    var uid : String?
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














