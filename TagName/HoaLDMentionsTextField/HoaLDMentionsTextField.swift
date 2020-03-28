//
//  HoaLDMentionsTextField.swift
//  TagName
//
//  Created by HoaLD on 3/26/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

enum HoaLDMentionsTextFieldTextChangeType: Int {
    case typeMentionSymbol = 0
    case typeSpaceBar
    case typeBackSpace
    case typeBackSpaceAtMention
    case typeNormal
}

class HoaLDMentionsTextField: UITextField {
    
    //full all data
    
    
    // data need controll
    var kMentionInfos = [MentionInfo]()
    var kMentionSymbol: Character = "@" // default value is @ [at]
    
    // detect mention Type
    public static func mentionsTextFieldTypeFrom(replacementString: String, kMentionSymbol: Character, kMentionInfos :[MentionInfo], currentCursorLocation: Int) -> (type: HoaLDMentionsTextFieldTextChangeType, mentionInfo: MentionInfo?) {
        if replacementString == String(kMentionSymbol) {
            return (.typeMentionSymbol, nil)
        }else if (strcmp(replacementString.cString(using: String.Encoding.utf8)!, "\\b") == -92) {
            for mentionInfo in kMentionInfos {
                if mentionInfo.range.location < currentCursorLocation
                    && (mentionInfo.range.location + mentionInfo.range.length) >= currentCursorLocation {
                    return (.typeBackSpaceAtMention, mentionInfo)
                }
            }
            return (.typeBackSpace, nil)
        } else {
            return (.typeNormal, nil)
        }
    }
    
    // insert MentionInfo to display Text
    func insertMentionInfo(mentionInfo: MentionInfo) {
        mentionInfo.range = NSRange(location: getCurrentCursorLocation() - 1, length: mentionInfo.name.count + 1)
        kMentionInfos.append(mentionInfo)
        self.insertText("\(mentionInfo.getDisplayName()) ")
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
