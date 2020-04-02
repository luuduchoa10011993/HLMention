//
//  HLMentionsTextField.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

class HLMentionsTextField: UITextField {
    
    //full all data or data need to setup
    var kListMentionInfos = [HLMentionInfo]()
    var kMentionSymbol: Character = "@" // default value is @ [at]
    
    // data need control
    private var kMentionInfos = [HLMentionInfo]()
    private var kMentionSearchingString = ""
    private var kMentionSearchingStringLocation = 0 // use for insert select mention in tableview
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
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
        self.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        HLrefreshDisplay()
        HLsetCurrentCursorLocation(index: kMentionCurrentCursorLocation)
    }
    
    // backspace data -> range (0,1), replacementString = ""
    // a -> range (1,0), replacementString = a
    public func dataTextField(range: NSRange, replacementString: String) -> (shouldChangeCharacters: Bool, mentionInfos: [HLMentionInfo]?) {

        // remove when editing word
        if let mentionInfos = mentionInfoInRange(range: range, replacementString: replacementString) {
            if let mentionInfo = mentionInfos.first,
                (replacementString.isEmpty || replacementString.count == 1) && mentionInfos.count == 1 {
                removeMentionInfoAndUpdateLocation(mention: mentionInfo)
                kMentionCurrentCursorLocation = mentionInfo.kRange.location + replacementString.count
                if replacementString.isValidCharacterBackSpace() {
                    kMentionCurrentCursorLocation -= range.length
                }
                return (true, nil)
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
            return (true, nil)
        }
        
        kMentionCurrentCursorLocation = range.location - range.length + replacementString.count
        if replacementString.isValidCharacterBackSpace() {
            kMentionCurrentCursorLocation += 1
        }
        if replacementString == " " {
            HLupdateMentionInfosRange(range: range, replacementString: replacementString)
            HLclearSearch()
            return (true, nil)
        }
        // search
        let currentWord = String(self.currentWord().dropLast(range.length)) + replacementString
        if isValidCurrentWordMentionSearch(currentWord: currentWord) {
            kMentionSearchingStringLocation = getCurrentCursorLocation() - range.length + replacementString.count
            kMentionSearchingString = String(currentWord.dropFirst(String(kMentionSymbol).count))
            HLupdateMentionInfosRange(range: range, replacementString: replacementString)
            return (true, mentionInfosSearchFrom(kMentionSearchingString))
        }
        
        HLupdateMentionInfosRange(range: range, replacementString: replacementString)
        HLclearSearch()
        
        if replacementString == String(kMentionSymbol) {
            kMentionSearchingStringLocation = range.location - range.length + replacementString.count
            return (true, kListMentionInfos)
        }
        return (true, nil)
    }
    
//    func HLreloadData() {
//        HLclearSearch()
//    }
    
    func HLclearSearch() {
        kMentionSearchingString.removeAll()
        kMentionSearchingStringLocation = 0
    }
    
    func HLrefreshDisplay() {
        if let string = text {
            attributedText = attributeStringrefeshMentionInfoWithColor(string: string, mentionInfos: kMentionInfos)
        }
    }
    
    func attributeStringrefeshMentionInfoWithColor(string: String, mentionInfos: [HLMentionInfo]) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: string,attributes: [ NSAttributedString.Key.foregroundColor: UIColor.darkText ])
        let attribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
        for mentionInfo in mentionInfos {
            attributeString.addAttributes(attribute, range: mentionInfo.kRange)
        }
        return NSAttributedString.init(attributedString: attributeString)
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
    
    func mentionInfoInRange(range: NSRange, replacementString: String) -> [HLMentionInfo]? {
        var mentionInfos = [HLMentionInfo]()
        let newRange: NSRange = {
            if replacementString.isValidCharacterBackSpace() {
                return NSRange(location: range.location + 1, length: range.length - 1)
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
            if (newRange.location < mentionInfo.kRange.location && mentionInfo.kRange.location <= sumRange)
            || (newRange.location <= sumRangeMentionInfo && sumRangeMentionInfo < sumRange)
            || (mentionInfo.kRange.location < sumRange && sumRange <= sumRangeMentionInfo){
                mentionInfos.append(mentionInfo)
            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
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
        HLclearSearch()
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

extension UITextField {
    func getCurrentCursorLocation() -> Int {
        if let selectedRange = self.selectedTextRange {
            return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        }
        return 0
    }

    func HLsetCurrentCursorLocation(index: Int) {
        let startPosition = self.position(from: self.beginningOfDocument, offset: index)
        let endPosition = self.position(from: self.beginningOfDocument, offset: index)

        if startPosition != nil && endPosition != nil {
            self.selectedTextRange = self.textRange(from: startPosition!, to: endPosition!)
        }
    }
    
    func currentWord() -> String {
        guard let cursorRange = self.selectedTextRange else { return "" }
        func getRange(from position: UITextPosition, offset: Int) -> UITextRange? {
            guard let newPosition = self.position(from: position, offset: offset) else { return nil }
            return self.textRange(from: newPosition, to: position)
        }

        var wordStartPosition: UITextPosition = self.beginningOfDocument
        var wordEndPosition: UITextPosition = self.endOfDocument

        var position = cursorRange.start

        while let range = getRange(from: position, offset: -1), let text = self.text(in: range) {
            if text == " " || text == "\n" {
                wordStartPosition = range.end
                break
            }
            position = range.start
        }

        position = cursorRange.start

        while let range = getRange(from: position, offset: 1), let text = self.text(in: range) {
            if text == " " || text == "\n" {
                wordEndPosition = range.start
                break
            }
            position = range.end
        }

        guard let wordRange = self.textRange(from: wordStartPosition, to: wordEndPosition) else { return "" }

        return self.text(in: wordRange) ?? ""
    }
}

extension String {
    
    func HDlowercase() -> String {
        return lowercased()
    }
    
    mutating func insertString(string: String, atIndex: Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: atIndex))
    }
    
    mutating func removeString(string: String, atIndex: Int) {
        let string = stringStartIndexTo(index: atIndex) + stringFromIndexToEndIndex(index: atIndex + string.count)
        self = string
    }

    mutating func removeStringWithRange(range: NSRange) {
        let string = stringStartIndexTo(index: range.location) + stringFromIndexToEndIndex(index: range.location + range.length)
        self = string
    }
    
    mutating func stringStartIndexTo(index: Int) -> String {
        let string = self
        let end = string.index(string.startIndex, offsetBy: index)
        let range = string.startIndex..<end
        return String(string[range])
    }
    
    mutating func stringFromIndexToEndIndex(index: Int) -> String {
        let string = self
        let start = string.index(string.startIndex, offsetBy: index)
        let range = start..<string.endIndex
        return String(string[range])
    }
    
    func isValidCharacterBackSpace() -> Bool {
        return (strcmp(self.cString(using: String.Encoding.utf8)!, "\\b") == -92)
    }
    
    //replace TagUserString -> TagUserRawString
    // Ex: "I'm [:[userID]:] and i live in Toronto
    mutating func stringRawToStringTagUser(_ userInfos: [HLMentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getDisplayName(), with: userInfo.getTagID())
        }
        return rawString
    }
    
    // Ex: "I'm @Lưu Đức Hoà and i live in Toronto
    mutating func stringTagUserToStringRaw(_ userInfos: [HLMentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getTagID(), with: userInfo.getDisplayName())
        }
        return rawString
    }
    
}
