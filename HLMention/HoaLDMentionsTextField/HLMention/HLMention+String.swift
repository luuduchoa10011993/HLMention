//
//  HLMention+String.swift
//  HLMention
//
//  Created by HoaLD on 4/4/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

extension String {
    
    func hlLowercase() -> String {
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
    
    mutating func stringFrom(start: Int, end: Int) -> String {
        let string = self
        let startString = string.index(string.startIndex, offsetBy: start)
        let endString = string.index(string.startIndex, offsetBy: end)
        return String(string[startString..<endString])
    }
    
    func isValidCharacterBackSpace() -> Bool {
        return (strcmp(self.cString(using: String.Encoding.utf8)!, "\\b") == -92)
    }
    
    //replace TagUserString -> TagUserRawString
    // Ex: "I'm [:[userID]:] and i live in Toronto
    mutating func stringRawToStringTagUser(_ userInfos: [HLMentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.kName, with: userInfo.getTagID())
        }
        return rawString
    }
    
    // Ex: "I'm @Lưu Đức Hoà and i live in Toronto
    mutating func stringTagUserToStringRaw(_ userInfos: [HLMentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getTagID(), with: userInfo.kName)
        }
        return rawString
    }
    
}
