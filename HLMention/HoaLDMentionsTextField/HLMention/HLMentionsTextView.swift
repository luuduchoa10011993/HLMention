//
//  HLMentionsTextView.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

protocol HLMentionsTextViewDelegate: class {
    func HLMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?)
    
    /* if you want anythings just add from UITextView delegate*/
}

class HLMentionsTextView: UITextView {
    
    weak var HLdelegate: HLMentionsTextViewDelegate?
    //full all data or data need to setup
    var HLtext: String = ""
    var kListMentionInfos = [HLMentionInfo]()
    var kMentionSymbol : Character = "@" // default value is @ [at]
    
    var HLfont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var hlTextColor : UIColor = UIColor.darkText
    var hlHighlightColor : UIColor = UIColor.red
    
    
    // data need control
    var kMentionInfos = [HLMentionInfo]()
    
    // search
    private var hlMentionSearchInfo = HLMentionSearchInfo()
    
    private var kLastCursorLocation = 0
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
    private var kMentionInfoRemoved: Bool = false

    // don't touch
    private var kMentionInfoInsertInfrontRange: NSRange?
    private var kUndoText = ""
    
    private var kRange = NSRange()
    private var kReplacementText = ""
    var kTextViewDidChange = true
    
//    var kMentionLastEditLocation: Int = 0
    
    func getTextAndMentionInfos() -> (text: String, mentionInfos: [HLMentionInfo])? {
        
        
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kMentionInfos {
            if mentionInfo.kAct == .typeAt {
                mentionInfos.append(mentionInfo)
            }
        }
        
        guard var mentionText = text else {
            return nil
        }
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return(mentionText, mentionInfos)
    }
    
    override func awakeFromNib() {
        self.delegate = self
        hlResetData()
        hlAttributeStringMentionInfo()
    }
    
    func hlResetData() {
        hlSetDisplayText()
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlMentionSearchInfo.removeAll()
    }
    
    func hlSetDisplayText() {
        var mentionText = HLtext
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: mentionInfo.getTagID(), with: "\(kMentionSymbol)\(mentionInfo.kName)")
        }
        text = mentionText
    }
    
    func hlGetMentionInfoText() -> String{
        guard var mentionText = text else {
            return ""
        }
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return mentionText
    }
    
    func hlAttributeStringMentionInfo() {
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
        attributedText.hlAttributeStringRemoveRanges()
        attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: kMentionInfos),
                                                     highLightColor: hlHighlightColor)
        self.attributedText = attributedText
    }
    
    func hlHandleSearch() -> [HLMentionInfo]? {
        var currentWord = self.currentWord()
        if currentWord.count > 0 {
            if currentWord.stringFrom(start: 0, end: 1) == String(kMentionSymbol) {
                hlMentionSearchInfo.kRange = NSRange(location: getCurrentWordLocation(), length: currentWord.count)
                hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                
                for mentionInfo in kMentionInfos {
                    if (mentionInfo.kRange.location + mentionInfo.kRange.length == hlMentionSearchInfo.kRange.location)
                        || mentionInfo.kName == hlMentionSearchInfo.kText {
                        return nil
                    }
                }
                
                return self.mentionInfosSearchFrom(hlMentionSearchInfo.kText)
            }
        }
        return nil
    }

    
    func rangeTextInsertInfrontMention(range: NSRange, replacementString: String) -> NSRange? {
        for mentionInfo in kMentionInfos {
            if range.location == mentionInfo.kRange.location {
                return NSRange(location: range.location, length: replacementString.count)
            }
        }
        return nil
    }
    
    func mentionInfosSearchFrom(_ string: String) -> [HLMentionInfo]? {
        if string.isEmpty { return kListMentionInfos }
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kListMentionInfos {
            if mentionInfo.kName.hlLowercase().contains(string.hlLowercase()) {
                mentionInfos.append(mentionInfo)
            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    func hlInsertMentionInfoWhenSearch(mentionInfo: HLMentionInfo) {
//        if hlMentionSearchInfo.kIsSearch {
            hlInsertMentionInfo(mentionInfo: mentionInfo, at: hlMentionSearchInfo.kRange)
//        }
    }
    
    func hlInsertMentionInfo(mentionInfo: HLMentionInfo,at range: NSRange) {
        guard let textRange = textRangeFromLocation(start: range.location, end: range.location + range.length) else { return }
        
        let insertString = String(kMentionSymbol) + mentionInfo.kName
        self.replace(textRange, withText: insertString)
        
        let mention = mentionInfo.copy() as! HLMentionInfo
        mention.kRange = NSRange(location: range.location,
                                 length: insertString.count)
        
        hlUpdateMentionInfosRange(range: NSRange(location: range.location, length: range.length), insertTextCount: insertString.count)
        self.kMentionInfos.append(mention)
        
        hlAttributeStringMentionInfo()
        hlSetCurrentCursorLocation(index: range.location + insertString.count)
        hlSetTypingAttributes()
        kTextViewDidChange = false
    }
    
    // remove MentionInfo
    func removeMentionInfoAndUpdateLocation(mentionInfo: HLMentionInfo) {
        if var string = text {
            string.removeStringWithRange(range: mentionInfo.kRange)
            text = string
            hlRemoveMentionInfo(mention: mentionInfo)
            hlUpdatekMentionInfosRemoveRange(range: mentionInfo.kRange)
            hlSetCurrentCursorLocation(index: mentionInfo.kRange.location)
        }
    }
    
    func hlRemoveMentionInfo(mention: HLMentionInfo) {
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        kMentionInfos.remove(at: mentionObject.mentionIndex)
    }
    
    func hlUpdateMentionLocation() {
        hlUpdateMentionInfosRange(range: kRange, insertTextCount: kReplacementText.count)
    }
    
    func hlUpdateMentionInfosRange(range: NSRange, insertTextCount: Int) {
        if kMentionInfos.isEmpty {
            return
        }
        if range.length > 0 {
            hlUpdatekMentionInfosRemoveRange(range: range)
        }
        
        if insertTextCount > 0 {
            hlUpdatekMentionInfosInsertRange(range: NSRange(location: range.location, length: insertTextCount))
        }
    }
    
    func hlUpdatekMentionInfosInsertRange(range: NSRange) {
        for mention in kMentionInfos {
            if (range.location > mention.kRange.location && range.location < mention.kRange.location + mention.kRange.length)
            || range.location <= mention.kRange.location {
                mention.kRange.location += range.length
            }
        }
    }
    
    func hlUpdatekMentionInfosRemoveRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location -= range.length
            }
        }
    }
    
}

extension HLMentionsTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // backspace data -> range (0,1), replacementString = ""
        // a -> range (1,0), replacementString = a
        kRange = range
        kReplacementText = text
        
        if text == String(kMentionSymbol) {
            hlMentionSearchInfo.kRange = NSRange(location: range.location, length:text.count)
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            return true
        }

        // remove when editing word
        if let mentionInfos = mentionInfoIsValidInRange(range: range, replacementString: text) {
            kMentionInfoRemoved = true
            if let mentionInfo = mentionInfos.first,
                (text.isEmpty || text.count == 1) && mentionInfos.count == 1 {
                
                if (range.location >= mentionInfo.kRange.location) && (range.location < mentionInfo.kRange.location + mentionInfo.kRange.length) {
                    guard let textRange = textRangeFromLocation(start: mentionInfo.kRange.location, end: mentionInfo.kRange.location + mentionInfo.kRange.length) else { return false}
                    hlRemoveMentionInfo(mention: mentionInfo)
                    kRange = mentionInfo.kRange
                    kReplacementText = ""
                    self.replace(textRange, withText: text)
                    return false
                }
                

                for mentionInfo in mentionInfos {
                    hlRemoveMentionInfo(mention: mentionInfo)
                }
                kMentionCurrentCursorLocation = range.location - range.length
//                removeMentionInfoAndUpdateLocation(mentionInfo: mentionInfo)

                
                
                kMentionCurrentCursorLocation = mentionInfo.kRange.location + text.count
                if text.isValidCharacterBackSpace() {
                    kMentionCurrentCursorLocation -= range.length
                }
                return false
            }
            
            // mention info have more than one and replacementStri@ng count > 1
            for mentionInfo in mentionInfos {
                hlRemoveMentionInfo(mention: mentionInfo)
            }
            kMentionCurrentCursorLocation = range.location - range.length
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {

        if !kTextViewDidChange {
            kTextViewDidChange = true
            return
        }
        
        let currentCursorLocation = getCurrentCursorLocation()
        if kUndoText.count != text.count && !kMentionInfos.isEmpty && !hlMentionSearchInfo.kIsSearch {
            hlUpdateMentionLocation()
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            hlUpdateMentionLocation()
        } else if let mentionInfos = hlHandleSearch() {
            if let delegate = HLdelegate {
                delegate.HLMentionsTextViewMentionInfos(self, mentionInfos: mentionInfos)
                return
            }
        }
        
        kLastCursorLocation = currentCursorLocation
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: currentCursorLocation)
        kUndoText = text
        
    }
}

