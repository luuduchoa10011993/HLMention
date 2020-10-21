//
//  HLMentionSearchInfo.swift
//  HLMention
//
//  Created by HoaLD on 4/6/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import Foundation

public class HLMentionSearchInfo: NSObject {
    
     // use for insert select mention in tableview. Ex: "@|H"
    public var kIsSearch = false
    public var kText = ""
    public var kRange = NSRange(location: 0,length: 0)
    public var kFirstTextAfterkText = ""
    public var kFirstTextAfterkTextRange = NSRange(location: 0,length: 0)
    
    
    func removeAll() {
        kIsSearch = false
        kText.removeAll()
        kRange = NSRange(location: 0,length: 0)
        kFirstTextAfterkText.removeAll()
        kFirstTextAfterkTextRange = NSRange(location: 0,length: 0)
    }
}
