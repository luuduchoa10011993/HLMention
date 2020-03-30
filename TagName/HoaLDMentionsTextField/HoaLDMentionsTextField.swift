//
//  HoaLDMentionsTextField.swift
//  TagName
//
//  Created by HoaLD on 3/26/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

enum HoaLDMentionsTextFieldTextChangeType: Int {
    case typeMentionSymbolAt = 0
    case typeMentionInfoSearch
    case typeMentionInfoSearchBackSpace
    case typeMentionInfoBackSpace
    case typeSpaceBar
    case typeNormal
}

class HoaLDMentionsTextField: UITextField {
    
    //full all data
    var kListMentionInfos = [MentionInfo]()
    
    // data need control
    var kMentionInfos = [MentionInfo]()
    var kMentionSymbol: Character = "@" // default value is @ [at]
    var kMentionType: HoaLDMentionsTextFieldTextChangeType = .typeNormal
    var kMentionLocation: Int = 0
    var kMentionSearching: Bool = false
    var kMentionSearchingString = ""
    
    
    func getAtMentionInfos() -> [MentionInfo]? {
        var mentionInfos = [MentionInfo]()
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
    
    public func dataTextField(range: NSRange, replacementString: String) -> (shouldChangeCharacters: Bool, mentionInfos: [MentionInfo]?) {
         
        // backspace data -> range (0,1), replacementString = ""
        // a -> range (1,0), replacementString = a

        if replacementString == " " {
            kMentionSearching = false
            return (true, nil)
        }
        
        //search
        let currentWord = String(self.currentWord().dropLast(range.length)) + replacementString
        if isValidCurrentWordMentionSearch(currentWord: currentWord) {
            kMentionSearchingString = String(currentWord.dropFirst(String(kMentionSymbol).count))
            return (true, mentionInfosSearchFrom(kMentionSearchingString))
        }
        
//        if kMentionSearching == true && kMentionLocation == range.location {
//            kMentionLocation = range.location + replacementString.count
//            kMentionSearchingString.append(Character(replacementString))
//            return (true, mentionInfosSearchFrom(kMentionSearchingString))
//        }
//
//        if kMentionSearching == true && (replacementString.isValidCharacterBackSpace() && (kMentionLocation - 1 == range.location)) {
//            kMentionLocation = range.location
//            kMentionSearchingString = String(kMentionSearchingString.dropLast())
//            return (true, mentionInfosSearchFrom(kMentionSearchingString))
//        }
        
        
        kMentionLocation = range.location + replacementString.count
        kMentionSearching = false
        kMentionSearchingString = ""
        
        
        // remove when editing word
        if let mentionInfos = mentionInfoInRange(range: range) {
            for mentionInfo in mentionInfos {
                removeMentionInfo(mention: mentionInfo)
            }
            return (false, nil)
        }
        
        if replacementString == String(kMentionSymbol) {
            kMentionSearching = true
            return (true, kListMentionInfos)
        }

        return (true, nil)
    }
    
    func isValidCurrentWordMentionSearch(currentWord: String) -> Bool {
        guard let firstCharacter = currentWord.first else {
            return false
        }
        if firstCharacter == kMentionSymbol {
            let word = String(currentWord.dropFirst(String(kMentionSymbol).count))
            let isValidNameFromMentionInfo = MentionInfo.isValidNameFromMentionInfo(mentionInfos: kListMentionInfos, name: word)
            return isValidNameFromMentionInfo
        }
        return false
    }
    
    /*
    // detect mention Type
    public func mentionsTextFieldTypeFrom(range: NSRange, replacementString: String) -> (type: HoaLDMentionsTextFieldTextChangeType, mentionInfo: MentionInfo?) {
        
        // type mention info
        
        // type search
        
        // type normal
        
        
        if replacementString == String(kMentionSymbol) {
            kMentionLocation = range.location + replacementString.count
            return (.typeMentionSymbolAt, nil)
        } else if (strcmp(replacementString.cString(using: String.Encoding.utf8)!, "\\b") == -92) {
            if let mentionInfos = mentionInfoInRange(range: range) {
//                if let mentionInfo = mentionInfos {
//                    switch mention.type {
//                    case .typeAt:
//                        return (.typeMentionInfoBackSpace, mentionInfo)
//                    case .typeSearch:
//                        return (.typeMentionInfoSearchBackSpace, mentionInfo) // at search but backspace
//                    }
//                }
            }
            return (.typeNormal, nil)
        } else if replacementString == " " {
            return (.typeSpaceBar, nil)
        } else if (kMentionLocation + replacementString.count) == (range.location + replacementString.count)
            && (kMentionType == .typeMentionSymbolAt || kMentionType == .typeMentionInfoSearch) { // insert string
            kMentionLocation = range.location + replacementString.count
            // get MentionInfo

            if let mention = mentionInfoInRange(range: range) {
//                if let mentionInfo = mention.mentionInfo {
//                    switch mention.type {
//                        case .typeAt:
//                            removeMentionInfo(mention: mention)
//                    case .typeSeach:
//
//                    }
                }
            }

            return (.typeMentionInfoSearch, nil)
        } else {
            return (.typeNormal, nil)
        }
    }
     */
    
    func mentionInfosSearchFrom(_ string: String) -> [MentionInfo]? {
        var mentionInfos = [MentionInfo]()
        for mentionInfo in kListMentionInfos {
            if mentionInfo.kName.lowercased().contains(string.lowercased()) {
                mentionInfos.append(mentionInfo)
            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    func mentionInfoInRange(range: NSRange) -> [MentionInfo]? {
        var mentionInfos = [MentionInfo]()
        // get mention info in mention infos saved
        for mentionInfo in kMentionInfos {
            if range.location < (mentionInfo.kRange.location + mentionInfo.kRange.length)
                && range.location > mentionInfo.kRange.location {
                mentionInfos.append(mentionInfo)
            }
        }
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    // insert MentionInfo to display Text
    func insertMentionInfo(mentionInfo: MentionInfo, atLocation location: Int) {
        if var string = text {
            if kMentionSearching {
                let newLocation = location - kMentionSearchingString.count
                string.removeString(string: kMentionSearchingString, atIndex: newLocation)
            }
            let insertString = "\(mentionInfo.getDisplayName()) "
            string.insertString(string: insertString, atIndex: location)
            text = string
            setCurremtCursorLocation(index: (location + insertString.count))
            mentionInfo.kRange = NSRange(location: location - 1, length: mentionInfo.getDisplayName().count + 1)
            updatekMentionInfosInsertRange(range: mentionInfo.kRange)
            kMentionInfos.append(mentionInfo)
            kMentionSearching = false
        }
    }
    
    // remove MentionInfo
    func removeMentionInfo(mention: MentionInfo) {
        guard let mentionObject = MentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        let mentionInfo = mentionObject.mentionInfo
        if var string = text {
            string.removeMentionInfo(mentionInfo: mentionInfo)
            text = string
            kMentionInfos.remove(at: mentionObject.mentionIndex)
            setCurremtCursorLocation(index: mentionInfo.kRange.location)
            updatekMentionInfosRemoveRange(range: mentionInfo.kRange)
        }
    }
    
    func updatekMentionInfosInsertRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location += range.length
            }
        }
    }
    
    func updatekMentionInfosRemoveRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location -= range.length
            }
        }
    }

    func setCurremtCursorLocation(index: Int) {
        let startPosition = self.position(from: self.beginningOfDocument, offset: index)
        let endPosition = self.position(from: self.beginningOfDocument, offset: index)
        
        if startPosition != nil && endPosition != nil {
            self.selectedTextRange = self.textRange(from: startPosition!, to: endPosition!)
        }
    }
    
    func refreshDisplay() {
        
    }
    
}

extension UITextField {
    //get CurrentCursorLocation, 0 mean selectedTextRange not found
    func getCurrentCursorLocation() -> Int {
        if let selectedRange = self.selectedTextRange {
            return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        }
        return 0
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
    mutating func insertString(string: String, atIndex: Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: atIndex))
    }
    
    mutating func removeString(string: String, atIndex: Int) {
        let string = stringStartIndexTo(index: atIndex) + stringFromIndexToEndIndex(index: atIndex + string.count)
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
    
    // Mention Info
    mutating func removeMentionInfo(mentionInfo: MentionInfo) {
        let string = stringStartIndexToMentionInfo(memtionInfo: mentionInfo) + stringMentionInfoToEndIndex(memtionInfo: mentionInfo)
        self = string
    }
    
    func stringStartIndexToMentionInfo(memtionInfo: MentionInfo) -> String {
        let string = self
        let end = string.index(string.startIndex, offsetBy: memtionInfo.kRange.location)
        let range = string.startIndex..<end
        return String(string[range])
    }
    
    func stringMentionInfoToEndIndex(memtionInfo: MentionInfo) -> String {
        let string = self
        let start = string.index(string.startIndex, offsetBy: (memtionInfo.kRange.location + memtionInfo.kRange.length))
        let range = start..<string.endIndex
        return String(string[range])
    }
    
    
    //replace TagUserString -> TagUserRawString
    // Ex: "I'm [:[userID]:] and i live in Toronto
    mutating func stringRawToStringTagUser(_ userInfos: [MentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getDisplayName(), with: userInfo.getTagID())
        }
        return rawString
    }
    
    // Ex: "I'm @Lưu Đức Hoà and i live in Toronto
    mutating func stringTagUserToStringRaw(_ userInfos: [MentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getTagID(), with: userInfo.getDisplayName())
        }
        return rawString
    }
    
}
