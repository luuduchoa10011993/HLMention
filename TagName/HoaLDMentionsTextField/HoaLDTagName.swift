//
//  HoaLDTagName.swift
//  TagName
//
//  Created by HoaLD on 3/25/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import Foundation
import UIKit

extension String {
    mutating func insertString(string: String, atIndex: Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: atIndex))
    }
    
    mutating func insertString(insertString: String, textField: UITextField, atCurrentCursorPosition: Bool){
        if atCurrentCursorPosition {
            var editedString = textField.text ?? ""
            if let selectedRange = textField.selectedTextRange {
                let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                editedString.insertString(string: insertString, atIndex: cursorPosition)
                self = editedString
            }
        }
    }
    
    //replace TagUserString -> TagUserRawString
    // Ex: "I'm [:[userID]:] and i live in Toronto
    mutating func stringRawToStringTagUser(_ userInfos: [MentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getDisplayTagName(), with: userInfo.getTagID())
        }
        return rawString
    }
    
    // Ex: "I'm @Lưu Đức Hoà and i live in Toronto
    mutating func stringTagUserToStringRaw(_ userInfos: [MentionInfo]) -> String {
        var rawString = self
        for userInfo in userInfos {
            rawString = rawString.replacingOccurrences(of: userInfo.getTagID(), with: userInfo.getDisplayTagName())
        }
        return rawString
    }
    
    
}
