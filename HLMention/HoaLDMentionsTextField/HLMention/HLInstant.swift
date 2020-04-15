//
//  HLInstant.swift
//  HLMention
//
//  Created by HoaLD on 4/9/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

class HLInstant {
    // iOS
//    public static var systemVersion = UIDevice.current.systemVersion
    
    var hlMentionInfosTableView = [HLMentionInfo]()
    var hlTableViewMax = 5
    
    var hlTableViewHeight: CGFloat = 220
    
    var hlMentionSymbol : Character = "@" // default value is @ [at]
    var hlText: String = ""
    var hlHighlightColor : UIColor = UIColor.red
    
    var kRange = NSRange()
    var kReplacementText = ""
    var hlMentionInfos = [HLMentionInfo]()
}

