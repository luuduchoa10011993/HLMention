//
//  HLMention+UITextView.swift
//  HLMention
//
//  Created by HoaLD on 4/4/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

extension UITextView {
    
    func hlSelectedTextRangeContentMentionRange(range: NSRange) -> Bool {
        guard let selectedRange = self.selectedTextRange else { return false }
        let startLocation = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        let endLocation = self.offset(from: self.beginningOfDocument, to: selectedRange.end)
        
        let rangeLength = range.location + range.length
        if startLocation <= range.location && rangeLength <= endLocation {
            return true
        } else if range.location > startLocation && range.location < endLocation && endLocation < rangeLength {
            return true
        } else if startLocation < range.location && range.location < endLocation {
            return true
        } else if startLocation < rangeLength && rangeLength < endLocation {
            return true
        }
        return false
    }
    func textRangeFromLocation(start: Int, end: Int) -> UITextRange? {
        let startPosition = self.position(from: self.beginningOfDocument, offset: start)
        let endPosition = self.position(from: self.beginningOfDocument, offset: end)
        if startPosition == nil && endPosition == nil {
            return nil
        }
        return textRange(from: startPosition!, to: endPosition!)
    }
    
    func getRange(from position: UITextPosition, offset: Int) -> UITextRange? {
        guard let newPosition = self.position(from: position, offset: offset) else { return nil }
        return self.textRange(from: newPosition, to: position)
    }
    
    func hlSelectedRange(from selectedRange: UITextRange) -> NSRange {
        let beginning: UITextPosition = self.beginningOfDocument

        let selectionStart: UITextPosition = selectedRange.start
        let selectionEnd: UITextPosition = selectedRange.end

        let location = self.offset(from: beginning, to: selectionStart)
        let length = self.offset(from: selectionStart, to: selectionEnd)

        return NSMakeRange(location, length)
    }
    
    func getCurrentCursorLocation() -> Int {
        if let selectedRange = self.selectedTextRange {
            return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        }
        return 0
    }
    
    func hlSetCurrentCursorLocation(index: Int) {
        let startPosition = self.position(from: self.beginningOfDocument, offset: index)
        let endPosition = self.position(from: self.beginningOfDocument, offset: index)

        if startPosition != nil && endPosition != nil {
            self.selectedTextRange = self.textRange(from: startPosition!, to: endPosition!)
        }
    }
    
    func getCurrentWordLocation() -> Int {
        guard let cursorRange = self.selectedTextRange else { return 0 }

        var wordStartPosition: UITextPosition = self.beginningOfDocument

        var position = cursorRange.start

        while let range = getRange(from: position, offset: -1), let text = self.text(in: range) {
            if text == " " || text == "\n" {
                wordStartPosition = range.end
                break
            }
            position = range.start
        }
        
        return self.offset(from: self.beginningOfDocument, to: wordStartPosition)
    }
    
    func currentWord() -> String {
        guard let cursorRange = self.selectedTextRange else { return "" }

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
