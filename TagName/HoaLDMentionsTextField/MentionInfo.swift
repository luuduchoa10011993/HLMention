//
//  UserModel.swift
//  TagName
//
//  Created by HoaLD on 3/25/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

enum MentionInfoType: String {
    case user = "user";
    case group = "group"
}

class MentionInfo: NSObject {
    var id = ""
    var name = ""
    var act = "with"
    var type: MentionInfoType = .user
    var range = NSRange(location: 0,length: 0)
    
    
    
//    var locationBeenMention = UITextRange
    
    init(_ id: String,_ name: String) {
        self.id = id
        self.name = name
    }
    
    func getDisplayName() -> String {
        return "\(name)"
    }
    
    func getTagID() -> String {
        return "::\(id)::"
    }
    
    static public func mentionInfoFromArray(mentionInfos: [MentionInfo], mentionInfo: MentionInfo) -> (mentionInfo: MentionInfo,mentionIndex: Int)? {
        var i = 0
        for mention in mentionInfos {
            if mention.id == mention.id {
                return (mention,i)
            }
            i += 1
        }
        return nil
    }
    
    /*
     {
       "text": "Ahihih ::5bbad28345e3ad05b340e316:: Đồ ngok",
       "sub": [
         {
           "what": "5bbad28345e3ad05b340e316",
           "act": "with",
           "name": "Nguyenn Annnnn",
           "type": "user"
         }
       ]
     }
     */
}
