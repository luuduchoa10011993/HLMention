//
//  HLMention+Display.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/5/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

extension HLMentionsTextView {
    
    func hlSetTypingAttributes() {
        let paraStyle: NSParagraphStyle = NSParagraphStyle()
        self.typingAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkText, NSAttributedString.Key.paragraphStyle : paraStyle, NSAttributedString.Key.font : HLfont]
    }
    
    func attributeString(attributedText: NSAttributedString, range: NSRange, color: UIColor) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(attributedString: attributedText)
        let attribute = [ NSAttributedString.Key.foregroundColor: color ]
        attributeString.addAttributes(attribute, range: range)
        return NSAttributedString.init(attributedString: attributeString)
    }
    
    func attributeStringRefeshMentionInfoWithColor(attributedText: NSAttributedString, mentionInfos: [HLMentionInfo], highLightColor: UIColor) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(attributedString: attributedText)
        let attribute = [ NSAttributedString.Key.foregroundColor: highLightColor ]
        for mentionInfo in mentionInfos {
            attributeString.addAttributes(attribute, range: mentionInfo.kRange)
        }
        return NSAttributedString.init(attributedString: attributeString)
    }
    
    
    
    
    
    
    
    
    

        /*
    func mentionInfoIsValidInRange(range: NSRange, replacementString: String) -> [HLMentionInfo]? {
        var mentionInfos = [HLMentionInfo]()
        let newRange: NSRange = {
            if replacementString.isValidCharacterBackSpace() {
                return range
                //                return NSRange(location: range.location + 1, length: range.length - 1)
            } else {
                return range
            }
        }()
        let sumRange = newRange.location + newRange.length
        for mentionInfo in kMentionInfos {
            let sumRangeMentionInfo = mentionInfo.kRange.location + mentionInfo.kRange.length
            /*
             @Hoa dep tr[ai @Nguyen Kieu Vy]
             @Hoa dep trai @Nguyen Ki[e]u Vy
             */
            if mentionInfo.kRange.location < range.location && range.location < sumRangeMentionInfo {
                mentionInfos.append(mentionInfo)
            }
            //            if (newRange.location < mentionInfo.kRange.location && mentionInfo.kRange.location <= sumRange)
            //            || (newRange.location < sumRangeMentionInfo && sumRangeMentionInfo < sumRange)
            //            || (mentionInfo.kRange.location < sumRange && sumRange < sumRangeMentionInfo) {
            //                mentionInfos.append(mentionInfo)
            //            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    public func dataTextView(range: NSRange, replacementString: String) -> [HLMentionInfo]? {
        kMentionCurrentCursorLocation = range.location
        // new rule
        
        // search
        let currentWord = String(self.currentWord().dropLast(range.length)) + replacementString
        if isValidCurrentWordMentionSearch(currentWord: currentWord) {
            let location = hlMentionSearchInfo.kRange.location
            if location - 1 > 0 {
                if hlMentionSearchInfo.kText.stringFrom(start: hlMentionSearchInfo.kRange.location - 1,
                                                        end: hlMentionSearchInfo.kRange.location) == " " {
                    hlMentionSearchInfo.kIsSearch = true
                    kMentionInfoInsertInfrontRange = NSRange(location: getCurrentCursorLocation() - range.length + replacementString.count, length: 0)
                    hlMentionSearchInfo.kText = String(currentWord.dropFirst(String(kMentionSymbol).count))
                    HLupdateMentionInfosRange(range: range, replacementString: replacementString)
                    return mentionInfosSearchFrom(hlMentionSearchInfo.kText)
                }
            } else {
                return mentionInfosSearchFrom(hlMentionSearchInfo.kText)
            }
        }
        
        if replacementString == " " {
            HLupdateMentionInfosRange(range: range, replacementString: replacementString)
            hlMentionSearchInfo.removeAll()
            return nil
        }
        
        // remove when editing word
        if let mentionInfos = mentionInfoIsValidInRange(range: range, replacementString: replacementString) {
            kMentionInfoRemoved = true
            if let mentionInfo = mentionInfos.first,
                (replacementString.isEmpty || replacementString.count == 1) && mentionInfos.count == 1 {
                removeMentionInfoAndUpdateLocation(mention: mentionInfo)
                kMentionCurrentCursorLocation = mentionInfo.kRange.location + replacementString.count
                if replacementString.isValidCharacterBackSpace() {
                    kMentionCurrentCursorLocation -= range.length
                }
                hlSetAttributeStringForMentionInfo()
                return nil
            }
            
            // mention info have more than one and replacementString count > 1
            for mentionInfo in mentionInfos {
                HLremoveMentionInfo(mention: mentionInfo)

                /*
                let sumLocationAndLength = range.location + range.length
                let sumLocationAndLengthMentionInfo = mentionInfo.kRange.location + mentionInfo.kRange.length

                if range.location >= mentionInfo.kRange.location && sumLocationAndLength <= sumLocationAndLengthMentionInfo {
                    HLremoveMentionInfo(mention: mentionInfo)
                }
                 */
            }
            kMentionCurrentCursorLocation = range.location - range.length
            hlSetAttributeStringForMentionInfo()
            return nil
        }

        if let range = rangeTextInsertInfrontMention(range: range, replacementString: replacementString) {
            kMentionInfoInsertInfrontRange = range
        }
        HLupdateMentionInfosRange(range: range, replacementString: replacementString)
        return nil
    }
    */
}
