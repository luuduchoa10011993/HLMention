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
    case typeMentionSymbolAtSearching
    case typeSpaceBar
    case typeBackSpace
    case typeBackSpaceAtMention
    case typeNormal
}

class HoaLDMentionsTextField: UITextField {
    
    //full all data
    var kListMentionInfos = [MentionInfo]()
    var kListSearchMentionInfos = [MentionInfo]()
    
    // data need controll
    var kMentionInfos = [MentionInfo]()
    var kMentionSymbol: Character = "@" // default value is @ [at]
    var kMentionType: HoaLDMentionsTextFieldTextChangeType = .typeNormal
    var kMentionLocation: Int = 0
    
    // detect mention Type
    public func mentionsTextFieldTypeFrom(range: NSRange, replacementString: String) -> (type: HoaLDMentionsTextFieldTextChangeType, mentionInfo: [MentionInfo]?) {
        if replacementString == String(kMentionSymbol) {
            kMentionLocation = range.location + replacementString.count
            return (.typeMentionSymbolAt, nil)
        }else if (strcmp(replacementString.cString(using: String.Encoding.utf8)!, "\\b") == -92) {
            for mentionInfo in kMentionInfos {
                if range.location < (mentionInfo.range.location + mentionInfo.range.length)
                    && range.location > mentionInfo.range.location {
                    return (.typeBackSpaceAtMention, [mentionInfo])
                }
            }
            return (.typeBackSpace, nil)
        } else if replacementString == " " {
            return (.typeSpaceBar, nil)
        } else if (kMentionLocation + replacementString.count) == (range.location + replacementString.count)
            && (kMentionType == .typeMentionSymbolAt || kMentionType == .typeMentionSymbolAtSearching) {
            kMentionLocation = range.location + replacementString.count
            return (.typeMentionSymbolAtSearching, nil)
        } else {
            return (.typeNormal, nil)
        }
    }
    
    // insert MentionInfo to display Text
    func insertMentionInfo(mentionInfo: MentionInfo, atLocation location: Int) {
        if var string = text {
            let insertString = "\(mentionInfo.getDisplayName()) "
            mentionInfo.range = NSRange(location: location - 1, length: insertString.count)
            string.insertString(string: insertString, atIndex: location)
            text = string
            setCurremtCursorLocation(index: (location + insertString.count))
            updatekMentionInfosWithInsert(mentionInfo: mentionInfo)
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
            setCurremtCursorLocation(index: mentionInfo.range.location)
            updatekMentionInfosWithRemove(mentionInfo: mention)
        }
    }
    
    func updatekMentionInfosWithInsert(mentionInfo: MentionInfo) {
        kMentionInfos.append(mentionInfo)
    }
    
    func updatekMentionInfosWithRemove(mentionInfo: MentionInfo) {
        for mention in kMentionInfos {
            if mention.range.location > mentionInfo.range.location {
                mention.range.location -= mentionInfo.range.length
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
}

extension String {
    mutating func insertString(string: String, atIndex: Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: atIndex))
    }
    
    mutating func removeMentionInfo(mentionInfo: MentionInfo) {
        let string = stringStartIndexToMentionInfo(memtionInfo: mentionInfo) + stringMentionInfoToEndIndex(memtionInfo: mentionInfo)
        self = string
    }
    
    func stringStartIndexToMentionInfo(memtionInfo: MentionInfo) -> String {
        let string = self
        let end = string.index(string.startIndex, offsetBy: memtionInfo.range.location)
        let range = string.startIndex..<end
        return String(string[range])
    }
    
    func stringMentionInfoToEndIndex(memtionInfo: MentionInfo) -> String {
        let string = self
        let start = string.index(string.startIndex, offsetBy: (memtionInfo.range.location + memtionInfo.range.length))
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
