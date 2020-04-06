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
    var HLtextColor : UIColor = UIColor.darkText
    var HLhighlightColor : UIColor = UIColor.red
    
    
    // data need control
    var kMentionInfos = [HLMentionInfo]()
    
    // search
    private var hlMentionSearchInfo = HLMentionSearchInfo()
    
    private var kLastCursorLocation = 0
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
    private var kMentionInfoRemoved: Bool = false
    private var kMentionInfoInsertInfrontRange: NSRange?

    // don't touch
    private var kRange = NSRange()
    private var kReplacementText = ""
    
//    var kMentionLastEditLocation: Int = 0
    
    func getTextAndMentionInfos() -> (text: String, mentionInfos: [HLMentionInfo]) {
        
        
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kMentionInfos {
            if mentionInfo.kAct == .typeAt {
                mentionInfos.append(mentionInfo)
            }
        }
        
        var mentionText = HLtext
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return(mentionText, mentionInfos)
    }
    
    override func awakeFromNib() {
        self.delegate = self
        hlResetData()
        hlSetAttributeStringForMentionInfo()
    }
    
    func hlResetData() {
        hlSetDisplayText()
        hlSetAttributeStringForMentionInfo()
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
    
    func hlSetAttributeStringForMentionInfo() {
        hlSetTypingAttributes()
        guard var attributedText = self.attributedText else { return }
        if !kMentionInfos.isEmpty {
            attributedText = attributeStringRefeshMentionInfoWithColor(attributedText: attributedText, mentionInfos: kMentionInfos, highLightColor: HLhighlightColor)
        }
        
//        if let insertInfrontRange = kMentionInfoInsertInfrontRange {
            attributedText = attributeString(attributedText: attributedText, range: insertInfrontRange, color: HLtextColor)
//        }
        self.attributedText = attributedText
    }
    
    func hlHandleSearch() -> [HLMentionInfo]? {
        var currentWord = self.currentWord()
        if currentWord.count > 0 {
            if currentWord.stringFrom(start: 0, end: 1) == String(kMentionSymbol) {
                hlMentionSearchInfo.kRange = NSRange(location: getCurrentWordLocation(), length: currentWord.count)
                hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                return self.mentionInfosSearchFrom(hlMentionSearchInfo.kText)
            }
        }
        return nil
    }
    
    func isValidCurrentWordMentionSearch(currentWord: String) -> Bool {
        guard let firstCharacter = currentWord.first else {
            return false
        }
        if firstCharacter == kMentionSymbol {
            let word = String(currentWord.dropFirst(String(kMentionSymbol).count))
            if word.isEmpty { return true }
            return HLMentionInfo.isValidNameFromMentionInfo(mentionInfos: kListMentionInfos, name: word.HDlowercase())
        }
        return false
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
            if mentionInfo.kName.HDlowercase().contains(string.HDlowercase()) {
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
        if hlMentionSearchInfo.kIsSearch {
            hlInsertMentionInfo(mentionInfo: mentionInfo, at: hlMentionSearchInfo.kRange)
        }
    }
    
    func hlInsertMentionInfo(mentionInfo: HLMentionInfo,at range: NSRange) {
        var mentionCurrentCursorLocation = range.location
        guard let textRange = textRangeFromLocation(start: range.location, end: range.location + range.length) else { return }
        
        let mention = mentionInfo.copy() as! HLMentionInfo
        let insertString = String(kMentionSymbol) + mention.kName
        mention.kRange = NSRange(location: range.location,
                                 length: insertString.count)
        self.kMentionInfos.append(mention)
        
        self.replace(textRange, withText: insertString)
        
        HLupdateMentionInfosRange(range: NSRange(location: range.location, length: range.length), replacementString: insertString)
        hlSetAttributeStringForMentionInfo()
//        hlSetCurrentCursorLocation(index: range.location + insertString.count)
    }
    
    func textRangeFromLocation(start: Int, end: Int) -> UITextRange? {
        let startPosition = self.position(from: self.beginningOfDocument, offset: start)
        let endPosition = self.position(from: self.beginningOfDocument, offset: end)
        if startPosition == nil && endPosition == nil {
            return nil
        }
        return textRange(from: startPosition!, to: endPosition!)
    }
    
    // remove MentionInfo
    func removeMentionInfoAndUpdateLocation(mention: HLMentionInfo) {
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        let mentionInfo = mentionObject.mentionInfo
        if var string = text {
            string.removeStringWithRange(range: mentionInfo.kRange)
            text = string
            kMentionInfos.remove(at: mentionObject.mentionIndex)
            hlUpdatekMentionInfosRemoveRange(range: mentionInfo.kRange)
            hlSetCurrentCursorLocation(index: mentionInfo.kRange.location)
        }
    }
    
    func HLremoveMentionInfo(mention: HLMentionInfo) {
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        kMentionInfos.remove(at: mentionObject.mentionIndex)
    }
    
    func HLremoveStringWithRange(range: NSRange) {
        if var string = text {
            string.removeStringWithRange(range: range)
            text = string
        }
    }
    
    // replacement-> add text, range.lenge = remove text
    func HLupdateMentionInfosRange(range: NSRange, replacementString: String) {
        if kMentionInfos.isEmpty {
            return
        }
        if range.length > 0 {
            hlUpdatekMentionInfosRemoveRange(range: range)
        }
        
        if !replacementString.isEmpty {
            hlUpdatekMentionInfosInsertRange(range: NSRange(location: range.location, length: replacementString.count))
        }
    }
    
    func hlupdateMentionInfosRange(range: NSRange, insertTextCount: Int) {
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
            if mention.kRange.location > range.location {
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
        // detect search
        
        if text == String(kMentionSymbol) {
            hlMentionSearchInfo.kIsSearch = true
            hlMentionSearchInfo.kRange = NSRange(location: range.location, length:text.count)
        }
        
//        if let delegate = HLdelegate {
//            let mentionInfos = dataTextView(range: range, replacementString: text)
//            delegate.HLMentionsTextViewMentionInfos(self, mentionInfos: mentionInfos)
//        }

//        HLupdateMentionInfosRange(range: range, replacementString: text)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        
        // getCurrentCursorLocation then check with getLastCursorLocation
        
        if let mentionInfos = hlHandleSearch() {
            if let delegate = HLdelegate {
                delegate.HLMentionsTextViewMentionInfos(self, mentionInfos: mentionInfos)
                return
            }
        }
        
        if kMentionInfoRemoved {
            hlSetAttributeStringForMentionInfo()
            kMentionInfoRemoved = false
        }
        
        
        let currentCursorLocation = getCurrentCursorLocation()
        if kLastCursorLocation != currentCursorLocation {
            hlupdateMentionInfosRange(range: kRange, insertTextCount: kReplacementText.count)
        }
        kLastCursorLocation = currentCursorLocation
        hlSetAttributeStringForMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: currentCursorLocation)
        
    }
}

