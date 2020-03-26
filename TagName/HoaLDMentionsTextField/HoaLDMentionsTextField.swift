//
//  HoaLDMentionsTextField.swift
//  TagName
//
//  Created by HoaLD on 3/26/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit

class HoaLDMentionsTextField: UITextField {
    var kUsers = [UserInfo]()
    var kStringRaw = ""
    
    func insertUser(userInfo: UserInfo, atCurrentCursorPosition: Bool){
        // cần remove cái @ ra trước khi insert vào nha 
        insertString(insertString: userInfo.getDisplayTagName(), atCurrentCursorPosition: atCurrentCursorPosition)
    }
    
    func insertString(insertString: String, atCurrentCursorPosition: Bool){
        if atCurrentCursorPosition {
            var editedString = self.text ?? ""
            if let selectedRange = self.selectedTextRange {
                let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
                editedString.insertString(string: insertString, atIndex: cursorPosition)
                self.text = editedString
            }
        }
    }
    
    func refreshDisplay() {
        text = kStringRaw.stringTagUserToStringRaw(kUsers)
    }
    
    //    self.delegate = HoaLDMentionsTextFieldDelegate
    /*
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         self.range = range
         self.replacementString = string

         let  char = string.cString(using: String.Encoding.utf8)!
         let isBackSpace = strcmp(char, "\\b")

         if (isBackSpace == -92) {
             let newRange = NSRange(location: range.location - 1, length: range.length)
             self.range = newRange
         }
         return true
     }
     */
    
}
