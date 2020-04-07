//
//  HLMention+NSMutableAttributedString.swift
//  HLMention
//
//  Created by HoaLD on 4/7/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    func hlAttributeStringRemoveRanges() {
        self.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSMakeRange(0, self.length))
    }
    
    func hlAttributeStringInsertRanges(ranges: [NSRange], highLightColor: UIColor) {
        let attribute = [ NSAttributedString.Key.foregroundColor: highLightColor ]
        for range in ranges {
            self.addAttributes(attribute, range: range)
        }
    }
}

