//
//  HoaLDMentionsTextField.swift
//  TagName
//
//  Created by HoaLD on 3/26/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

class HoaLDMentionsTextField: UITextField {
    
    var kMentionInfos = [MentionInfo]()
    var kMentionSymbol: Character = "@" // default value is @
    
    // insert User to display Text
    func insertUser(mentionInfo: MentionInfo) {
        self.deleteBackward()
        mentionInfo.range = NSRange(location: getCurrentCursorLocation(), length: mentionInfo.name.count)
        kMentionInfos.append(mentionInfo)
        self.insertText("\(mentionInfo.getDisplayName()) ")
    }
    
    func removeMentionInfo(mention: MentionInfo) {
        guard let mentionObject = MentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        
        let mentionInfo = mentionObject.mentionInfo
        // remove mentionInfo from display
        if var string = self.text {
            kMentionInfos.remove(at: mentionObject.mentionIndex)
            string.removeMentionInfo(mentionInfo: mentionInfo)
            text = string
            setCurremtCursorLocation(index: mentionInfo.range.location)
        }
        
        updateMentionInfosWhenRemoveMentionInfo(mentionInfo: mention)
    }
    
    func updateMentionInfosWhenRemoveMentionInfo(mentionInfo: MentionInfo) {
        for mention in kMentionInfos {
            if mention.range.location > mentionInfo.range.location {
                mention.range.location -= mentionInfo.range.length
            }
        }
    }
    
    //get CurrentCursorLocation, 0 mean selectedTextRange not found
    func getCurrentCursorLocation() -> Int {
        if let selectedRange = self.selectedTextRange {
            return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        }
        return 0
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
        let end = self.index(self.endIndex, offsetBy: (0 - (memtionInfo.range.location + memtionInfo.range.length)))
        let range = self.startIndex..<end
        return String(string[range])
    }
    
    func stringMentionInfoToEndIndex(memtionInfo: MentionInfo) -> String {
        let string = self
        let start = self.index(self.startIndex, offsetBy: memtionInfo.range.location)
        let range = start..<self.endIndex
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
