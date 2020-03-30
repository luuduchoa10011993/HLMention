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

enum MentionInfoActType: String {
    case typeAt = "with";
    case typeSearch = "search" // if want to be a search name must have at least 1 charater
}

class MentionInfo: NSObject {
    var kId = ""
    var kName = ""
    var kAct: MentionInfoActType = .typeAt
    var kType: MentionInfoType = .user
    var kRange = NSRange(location: 0,length: 0)
    
    
    
//    var locationBeenMention = UITextRange
    
    init(_ id: String,_ name: String) {
        self.kId = id
        self.kName = name
    }
    
    func getTagID() -> String {
        return "::\(kId)::"
    }
    
    func getDisplayName() -> String {
        return "\(kName)"
    }
    
    static public func mentionInfoFromArray(mentionInfos: [MentionInfo], mentionInfo: MentionInfo) -> (mentionInfo: MentionInfo,mentionIndex: Int)? {
        var i = 0
        for mention in mentionInfos {
            if mention.kId == mentionInfo.kId {
                return (mention,i)
            }
            i += 1
        }
        return nil
    }
    
    static public func isValidNameFromMentionInfo(mentionInfos: [MentionInfo], name: String) -> Bool {
        for mention in mentionInfos {
            if mention.kName.lowercased().contains(name) {
                return true
            }
        }
        return false
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
