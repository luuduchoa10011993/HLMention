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
    
    
//    var locationBeenMention = UITextRange
    
    init(_ id: String,_ name: String) {
        self.id = id
        self.name = name
    }
    
    func getDisplayTagName() -> String {
        return "\(name)"
    }
    
    func getTagID() -> String {
        return "::\(id)::"
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
