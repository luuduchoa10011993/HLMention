//
//  HLInstant.swift
//  HLMention
//
//  Created by HoaLD on 4/9/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

public class HLInstant {
    // iOS
//    public static var systemVersion = UIDevice.current.systemVersion
    private var _hlMentionInfosTableView = [HLMentionInfo]() // display on tableview
    public var hlMentionInfosTableView: [HLMentionInfo]! {
        get {
            return _hlMentionInfosTableView
        }
        
        set {
            var mentionInfosTableView = [HLMentionInfo]()
            for value in newValue {
                if !checkIfAlreadyMention(mention: value) {
                    mentionInfosTableView.append(value)
                }
            }
            _hlMentionInfosTableView = mentionInfosTableView
        }
    }
    
    
    
    
    public var hlTableViewBackgroundColor: UIColor = UIColor.white
    public var hlTableViewMax: Int = 999
    public var hlTableViewHeight: CGFloat = 100
    public var hlTableViewCellHeight: CGFloat?
    public var hlTableViewBorderColor: CGColor = UIColor.black.withAlphaComponent(0.8).cgColor
    public var hlTableViewBorderWidth: CGFloat = 1.0
    public var hlTableViewCornerRadius: CGFloat = 5.0
    public var hlTableViewMasksToBounds: Bool = true
    
    //HL Search offline data
    public var hlHighlightColor : UIColor = UIColor.red
    public var hlText: String = ""
    public var hlInsertMentionInfoWithMentionSymbol: Bool = false
    public var hlMentionSymbol : Character = "@" // default value is @ [at]
    private var _hlListMentionInfos: [HLMentionInfo]?
    public var hlListMentionInfos: [HLMentionInfo]? {
        get {
            return _hlListMentionInfos
        }
        set {
            if hlInsertMentionInfoWithMentionSymbol == false {
                _hlListMentionInfos = newValue
            } else {
                if let newValue = newValue {
//                    var data = [HLMentionInfo]()
                    newValue.forEach { (mention) in
                        mention.kName = "\(hlMentionSymbol)\(mention.kName)"
                        mention.kRange = NSRange(location: mention.kRange.location, length: mention.kRange.length + 1) // hlMentionSymbol = 1
                    }
                    _hlListMentionInfos = newValue
                }
            }
        }
    }
    
    public var hlRange = NSRange() /* don't touch */
    public var hlReplacementText = "" /* don't touch */
    public var hlMentionInfos = [HLMentionInfo]() /* store mention */
    
    // search
    public var hlMentionSearchInfo = HLMentionSearchInfo() /* don't touch */
    public var hlHowManyCharacterBeginSearch: Int = 0
    
    
    
    public func checkIfAlreadyMention(mention: HLMentionInfo) -> Bool {
        if hlMentionInfos.isEmpty {
            return false
        }
        for mentionInfo in hlMentionInfos {
            if mentionInfo.kId == mention.kId {
                return true
            }
        }
        return false
    }
    
    public func getHLMentionInfos() -> [HLMentionInfo] {
        if hlInsertMentionInfoWithMentionSymbol == true {
            hlMentionInfos.forEach { (mention) in
                mention.kName = String(mention.kName.dropFirst(1))
            }
        }
        return hlMentionInfos
    }
}
