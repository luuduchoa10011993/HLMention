//
//  HLMentionsTextView.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

protocol HLMentionsTextViewDelegate: class {
    func HLMentionsTextViewMentionInfos(_ TextView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?)
    
    /* if you want anythings just add from UITextView delegate*/
}

class HLMentionsTextView: UITextView {
    
    weak var HLdelegate: HLMentionsTextViewDelegate?
    //full all data or data need to setup
    var kListMentionInfos = [HLMentionInfo]()
    var kMentionSymbol : Character = "@" // default value is @ [at]
    
    var HLfont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var HLtextColor : UIColor = UIColor.darkText
    var HLhighlightColor : UIColor = UIColor.red
    
    
    // data need control
    private var kMentionInfos = [HLMentionInfo]()
    private var kMentionSearchingString = ""
    private var kMentionSearchingStringLocation = 0 // use for insert select mention in tableview
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
    private var kMentionInfoRemoved: Bool = false
    private var kMentionInfoInsertInfrontRange: NSRange?

//    var kMentionLastEditLocation: Int = 0

    func getAtMentionInfos() -> [HLMentionInfo]? {
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kMentionInfos {
            if mentionInfo.kAct == .typeAt {
                mentionInfos.append(mentionInfo)
            }
        }
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        self.delegate = self
        HLclearSearch()
        HLrefreshDisplay()
    }
    
    func HLclearSearch() {
        kMentionSearchingString.removeAll()
        kMentionSearchingStringLocation = 0
    }
    
    func HLrefreshDisplay() {
        HLclearSearch()
        HLresetTypingAttributes()
        guard var attributedText = self.attributedText else { return }
        if !kMentionInfos.isEmpty {
            attributedText = attributeStringRefeshMentionInfoWithColor(attributedText: attributedText, mentionInfos: kMentionInfos, highLightColor: HLhighlightColor)
        }
        
        if let insertInfrontRange = kMentionInfoInsertInfrontRange {
            attributedText = attributeString(attributedText: attributedText, range: insertInfrontRange, color: HLtextColor)
        }
        self.attributedText = attributedText
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
    
    func HLresetTypingAttributes() {
        let paraStyle: NSParagraphStyle = NSParagraphStyle()
        self.typingAttributes = [NSAttributedString.Key.foregroundColor : UIColor.darkText, NSAttributedString.Key.paragraphStyle : paraStyle, NSAttributedString.Key.font : HLfont]
        
    }
    
    // backspace data -> range (0,1), replacementString = ""
    // a -> range (1,0), replacementString = a
    public func dataTextView(range: NSRange, replacementString: String) -> [HLMentionInfo]? {
        kMentionCurrentCursorLocation = range.location
        // new rule
        
        // search
        let currentWord = String(self.currentWord().dropLast(range.length)) + replacementString
        if isValidCurrentWordMentionSearch(currentWord: currentWord) {
            kMentionSearchingStringLocation = getCurrentCursorLocation() - range.length + replacementString.count
            kMentionSearchingString = String(currentWord.dropFirst(String(kMentionSymbol).count))
            HLupdateMentionInfosRange(range: range, replacementString: replacementString)
            return mentionInfosSearchFrom(kMentionSearchingString)
        }
        
        if replacementString == " " {
            HLupdateMentionInfosRange(range: range, replacementString: replacementString)
            HLclearSearch()
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
                HLrefreshDisplay()
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
            HLrefreshDisplay()
            return nil
        }

        if let range = rangeTextInsertInfrontMention(range: range, replacementString: replacementString) {
            kMentionInfoInsertInfrontRange = range
        }
        HLupdateMentionInfosRange(range: range, replacementString: replacementString)
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
    
    func insertMentionInfoWhenSearching(mentionInfo: HLMentionInfo) {
        // "@Hoa dep trai @ho vkl @Nguyen Kieu Vy"
        // "@Hoa dep trai @Hoa vkl @Nguyen Kieu Vy"
        guard var string = text else { return }
        var mentionCurrentCursorLocation = kMentionSearchingStringLocation
        if kMentionSearchingString.count > 0 {
            mentionCurrentCursorLocation -= kMentionSearchingString.count
            string.removeStringWithRange(range: NSRange(location: mentionCurrentCursorLocation, length: kMentionSearchingString.count))
        }
        let insertString = "\(mentionInfo.getDisplayName()) "
        string.insertString(string: insertString, atIndex: mentionCurrentCursorLocation)
        
        text = string
        mentionInfo.kRange = NSRange(location: mentionCurrentCursorLocation - String(kMentionSymbol).count, length: String(kMentionSymbol).count + mentionInfo.getDisplayName().count)
        kMentionInfos.append(mentionInfo)
        HLupdateMentionInfosRange(range: NSRange(location: mentionCurrentCursorLocation, length: kMentionSearchingString.count), replacementString: insertString)

        kMentionCurrentCursorLocation = mentionCurrentCursorLocation + insertString.count
        HLrefreshDisplay()
        HLsetCurrentCursorLocation(index: kMentionCurrentCursorLocation)
    }
    
    // remove MentionInfo
    func removeMentionInfoAndUpdateLocation(mention: HLMentionInfo) {
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        let mentionInfo = mentionObject.mentionInfo
        if var string = text {
            string.removeStringWithRange(range: mentionInfo.kRange)
            text = string
            kMentionInfos.remove(at: mentionObject.mentionIndex)
            HLupdatekMentionInfosRemoveRange(range: mentionInfo.kRange)
            HLsetCurrentCursorLocation(index: mentionInfo.kRange.location)
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
    
    func HLupdateMentionInfosRange(range: NSRange, replacementString: String) {
        if kMentionInfos.isEmpty {
            return
        }
        if range.length > 0 {
            HLupdatekMentionInfosRemoveRange(range: range)
        }
        
        if !replacementString.isEmpty {
            HLupdatekMentionInfosInsertRange(range: NSRange(location: range.location, length: replacementString.count))
        }
    }
    
    func HLupdatekMentionInfosInsertRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location >= range.location {
                mention.kRange.location += range.length
            }
        }
    }
    
    func HLupdatekMentionInfosRemoveRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location -= range.length
            }
        }
    }
    
}

extension HLMentionsTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let delegate = HLdelegate {
            let mentionInfos = dataTextView(range: range, replacementString: text)
            delegate.HLMentionsTextViewMentionInfos(self, mentionInfos: mentionInfos)
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if kMentionInfoRemoved {
            HLrefreshDisplay()
            kMentionInfoRemoved = false
        }
        //if insert first letter before mention
        if kMentionInfoInsertInfrontRange != nil {
            HLrefreshDisplay()
            kMentionInfoInsertInfrontRange = nil
        }
        let currentCursorLocation = getCurrentCursorLocation()
        HLsetCurrentCursorLocation(index: currentCursorLocation)
    }
}

