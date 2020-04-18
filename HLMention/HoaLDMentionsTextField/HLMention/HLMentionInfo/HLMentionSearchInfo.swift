//
//  HLMentionSearchInfo.swift
//  HLMention
//
//  Created by HoaLD on 4/6/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import Foundation

class HLMentionSearchInfo: NSObject {
    
     // use for insert select mention in tableview. Ex: "@|H"
    var kIsSearch = false
    var kText = ""
    var kRange = NSRange(location: 0,length: 0)
    var kFirstTextAfterkText = ""
    var kFirstTextAfterkTextRange = NSRange(location: 0,length: 0)
    
    
    func removeAll() {
        kIsSearch = false
        kText.removeAll()
        kRange = NSRange(location: 0,length: 0)
        kFirstTextAfterkText.removeAll()
        kFirstTextAfterkTextRange = NSRange(location: 0,length: 0)
    }
}
