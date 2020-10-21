//
//  HLMention+NSMutableAttributedString.swift
//  HLMention
//
//  Created by HoaLD on 4/7/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    func hlAttributeStringRemoveAttributes() {
        self.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSMakeRange(0, self.length))
    }
    
    public func hlAttributeStringInsertRanges(ranges: [NSRange], highLightColor: UIColor, boldFont: UIFont?) {
        if boldFont != nil {
            let attribute = [ NSAttributedString.Key.foregroundColor: highLightColor, NSAttributedString.Key.font: boldFont ]
            for range in ranges {
                self.addAttributes(attribute as [NSAttributedString.Key : Any], range: range)
            }
        } else {
            let attribute = [ NSAttributedString.Key.foregroundColor: highLightColor ]
            for range in ranges {
                self.addAttributes(attribute, range: range)
            }
        }
    }
    
    public func hlAttributeStringReplace(range: NSRange,with text: String) {
        self.replaceCharacters(in: range, with: text)
    }
    
    public func setAsLink(range: NSRange, linkURL:String) {
        if range.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: range)
        }
    }
}

