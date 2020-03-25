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
    mutating func insertString(string:String, atIndex:Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: index))
    }
}

extension UITextField {
    func insertString(insertString: String, atCurrentCursorPosition: Bool) {
        if atCurrentCursorPosition {
            var editedString = self.text ?? ""
            if let selectedRange = self.selectedTextRange {
                let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
                editedString.insertString(string: insertString, index: cursorPosition)
                self.text = editedString
            }
        }
    }
}
