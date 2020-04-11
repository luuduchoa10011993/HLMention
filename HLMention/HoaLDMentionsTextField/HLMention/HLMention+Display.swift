//
//  HLMention+Display.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/5/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit


extension HLMentionsTextView {
    
    func hlAttributeRangesFrom(mentionInfos: [HLMentionInfo]) -> [NSRange] {
        var ranges = [NSRange]()
        for mentionInfo in mentionInfos {
            ranges.append(mentionInfo.kRange)
        }
        return ranges
    }
    
    func hlSetTypingAttributes() {
        let paraStyle: NSParagraphStyle = NSParagraphStyle()
        self.typingAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkText, NSAttributedString.Key.paragraphStyle : paraStyle, NSAttributedString.Key.font : hlFont]
    }

    /* for swift 4.2 then open this */
    /*
     func hlSetTypingAttributes() {
         let paraStyle: NSParagraphStyle = NSParagraphStyle()
         self.typingAttributes[NSAttributedString.Key.foregroundColor.rawValue] = UIColor.darkText
         self.typingAttributes[NSAttributedString.Key.paragraphStyle.rawValue] = paraStyle
         self.typingAttributes[NSAttributedString.Key.font.rawValue] = hlFont
     }
     */
    
    func mentionInfoIsValidInRange(range: NSRange, replacementString: String) -> [HLMentionInfo]? {
        var mentionInfos = [HLMentionInfo]()
        let newRange: NSRange = {
            if replacementString.isValidCharacterBackSpace() {
                return range
            } else {
                return range
            }
        }()
        
        let sumRange = newRange.location + newRange.length
        for mentionInfo in kMentionInfos {
            if hlSelectedTextRangeContentMentionRange(range: mentionInfo.kRange) {
                mentionInfos.append(mentionInfo)
            } else {
                let sumRangeMentionInfo = mentionInfo.kRange.location + mentionInfo.kRange.length
                /*
                 @Hoa dep tr[ai @Nguyen Kieu Vy]
                 @Hoa dep trai @Nguyen Ki[e]u Vy
                 */
                if mentionInfo.kRange.location < range.location && range.location < sumRangeMentionInfo {
                    mentionInfos.append(mentionInfo)
                } else if (range.location < mentionInfo.kRange.location) && (sumRangeMentionInfo < sumRange) {
                    mentionInfos.append(mentionInfo)
                }
            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
}
