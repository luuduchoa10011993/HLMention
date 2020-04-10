//
//  HLMentionsTextView.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

@objc protocol HLMentionsTextViewDelegate: class {
    @objc optional func hlMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?)
    @objc optional func hlMentionsTextViewCallBackFromSearch(_ textView: HLMentionsTextView, searchText: String)
    
    /* if you want anythings just add from UITextView delegate*/
}

class HLMentionsTextView: UITextView {
    
    /* TableView object*/
    @IBOutlet weak var hlTableView: UITableView?
    @IBOutlet weak var hlTableViewDataSource: UITableViewDataSource?
    @IBOutlet weak var hlTableViewDelegate: UITableViewDelegate?
    @IBOutlet weak var hlTableViewHeightConstaint: NSLayoutConstraint!
    
    var hlTableViewHeight: CGFloat = 220
    var _hlMentionInfosTableView = [HLMentionInfo]()
    var hlMentionInfosTableView:[HLMentionInfo] {
        get {
            return _hlMentionInfosTableView
        }
        set {
            _hlMentionInfosTableView = newValue
            if let tableView = hlTableView {
                tableView.reloadData()
            }
        }
    }
    
    
    weak var hlDelegate: HLMentionsTextViewDelegate?
    
    //full all data or data need to setup
    var HLtext: String = ""
    var kListMentionInfos: [HLMentionInfo]?
    var kMentionSymbol : Character = "@" // default value is @ [at]
    
    var hlFont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var hlTextColor : UIColor = UIColor.darkText
    var hlHighlightColor : UIColor = UIColor.red
    
    
    // data need control
    var kMentionInfos = [HLMentionInfo]()
    
    
    // search
    var hlMentionSearchInfo = HLMentionSearchInfo()
    
    private var kLastCursorLocation = 0
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
    private var kMentionInfoRemoved: Bool = false

    // don't touch
    private var kMentionInfoInsertInfrontRange: NSRange?
    private var kUndoText = ""
    
    private var kRange = NSRange()
    private var kReplacementText = ""
    var kTextViewDidChange = true
    
//    var kMentionLastEditLocation: Int = 0
    
    func getTextAndMentionInfos() -> (attributeText: NSAttributedString, mentionInfos: [HLMentionInfo])? {
        
        
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kMentionInfos {
            if mentionInfo.kAct == .typeAt {
                mentionInfos.append(mentionInfo)
            }
        }
        
        let mentionAttributeText = NSMutableAttributedString(attributedString: attributedText)
        mentionAttributeText.hlAttributeStringRemoveAttributes()
        for mentionInfo in kMentionInfos {
            mentionAttributeText.replaceCharacters(in: mentionInfo.kRange, with: mentionInfo.getTagID())
//            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return(mentionAttributeText, mentionInfos)
    }
    
    override func awakeFromNib() {
        hlResetData()
        hlAttributeStringMentionInfo()
        hlInitTableView()
    }
    
    func hlInitTableView() {
        guard let tableView = hlTableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: String(describing: HLMentionTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: HLMentionTableViewCell.self))
        
        let layer: CALayer = tableView.layer
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        if hlTableViewHeightConstaint.constant > 0 {
            hlTableViewHeight = hlTableViewHeightConstaint.constant
        }
    }
    
    func hlResetData() {
        hlSetDisplayText()
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlMentionSearchInfo.removeAll()
        _hlMentionInfosTableView.removeAll()
    }
    
    func hlSetDisplayText() {
        var mentionText = HLtext
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: mentionInfo.getTagID(), with: "\(kMentionSymbol)\(mentionInfo.kName)")
        }
        text = mentionText
    }
    
    func hlGetMentionInfoText() -> String{
        guard var mentionText = text else {
            return ""
        }
        for mentionInfo in kMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return mentionText
    }
    
    func hlAttributeStringMentionInfo() {
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
        attributedText.hlAttributeStringRemoveAttributes()
        attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: kMentionInfos),
                                                     highLightColor: hlHighlightColor)
        self.attributedText = attributedText
    }
    
    func hlHandleSearch(from kMentionInfos: [HLMentionInfo]) -> [HLMentionInfo]? {
        var currentWord = self.currentWord()
        if currentWord.count > 0 {
            if currentWord.stringFrom(start: 0, end: 1) == String(kMentionSymbol) {
                hlMentionSearchInfo.kRange = NSRange(location: getCurrentWordLocation(), length: currentWord.count)
                hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                
                if hlMentionSearchInfo.kText.isEmpty {
                    return self.mentionInfosSearchFrom(hlMentionSearchInfo.kText,from: kMentionInfos)
                }
                
                for mentionInfo in kMentionInfos {
                    if (mentionInfo.kRange.location + mentionInfo.kRange.length == hlMentionSearchInfo.kRange.location)
                        || mentionInfo.kName == hlMentionSearchInfo.kText {
                        return nil
                    }
                }
                
                return self.mentionInfosSearchFrom(hlMentionSearchInfo.kText,from: kMentionInfos)
            }
        }
        return nil
    }

    func hlHandleSearchString() -> String? {
        var currentWord = self.currentWord()
        if currentWord.count > 0 {
            if currentWord.stringFrom(start: 0, end: 1) == String(kMentionSymbol) {
                hlMentionSearchInfo.kRange = NSRange(location: getCurrentWordLocation(), length: currentWord.count)
                hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                return hlMentionSearchInfo.kText
            }
        }
        return nil
    }
    
    func rangeTextInsertInfrontMention(range: NSRange, replacementString: String) -> NSRange? {
        for mentionInfo in kMentionInfos {
            if range.location == mentionInfo.kRange.location {
                return NSRange(location: range.location, length: replacementString.count)
            }
        }
        return nil
    }
    
    func mentionInfosSearchFrom(_ string: String,from kListMentionInfos: [HLMentionInfo]) -> [HLMentionInfo]? {
        if string.isEmpty { return kListMentionInfos }
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in kListMentionInfos {
            if mentionInfo.kName.hlLowercase().contains(string.hlLowercase()) {
                mentionInfos.append(mentionInfo)
            }
        }
        
        if mentionInfos.count > 0 {
            return mentionInfos
        } else {
            return nil
        }
    }
    
    func hlInsertMentionInfo(mentionInfo: HLMentionInfo,at range: NSRange) {
        guard let textRange = textRangeFromLocation(start: range.location, end: range.location + range.length) else { return }
        
        let insertString = String(kMentionSymbol) + mentionInfo.kName
        
        let mention = mentionInfo.copy() as! HLMentionInfo
        mention.kRange = NSRange(location: range.location,
                                 length: insertString.count)
        
        hlUpdateMentionInfosRange(range: NSRange(location: range.location, length: range.length), insertTextCount: insertString.count)
        self.kMentionInfos.append(mention)
        
        kTextViewDidChange = false
        self.replace(textRange, withText: insertString)
        hlSetCurrentCursorLocation(index: range.location + insertString.count)
    }
    
    // remove MentionInfo
    func removeMentionInfoAndUpdateLocation(mentionInfo: HLMentionInfo) {
        if var string = text {
            string.removeStringWithRange(range: mentionInfo.kRange)
            text = string
            hlRemoveMentionInfo(mention: mentionInfo)
            hlUpdatekMentionInfosRemoveRange(range: mentionInfo.kRange)
            hlSetCurrentCursorLocation(index: mentionInfo.kRange.location)
        }
    }
    
    func hlRemoveMentionInfo(mention: HLMentionInfo) {
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: kMentionInfos, mentionInfo: mention) else { return }
        kMentionInfos.remove(at: mentionObject.mentionIndex)
    }
    
    func hlUpdateMentionLocation() {
        hlUpdateMentionInfosRange(range: kRange, insertTextCount: kReplacementText.count)
    }
    
    func hlUpdateMentionInfosRange(range: NSRange, insertTextCount: Int) {
        if kMentionInfos.isEmpty {
            return
        }
        if range.length > 0 {
            hlUpdatekMentionInfosRemoveRange(range: range)
        }
        
        if insertTextCount > 0 {
            hlUpdatekMentionInfosInsertRange(range: NSRange(location: range.location, length: insertTextCount))
        }
    }
    
    func hlUpdatekMentionInfosInsertRange(range: NSRange) {
        for mention in kMentionInfos {
            if (range.location > mention.kRange.location && range.location < mention.kRange.location + mention.kRange.length)
            || range.location <= mention.kRange.location {
                mention.kRange.location += range.length
            }
        }
    }
    
    func hlUpdatekMentionInfosRemoveRange(range: NSRange) {
        for mention in kMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location -= range.length
            }
        }
    }
    
    func hlTextView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // backspace data -> range (0,1), replacementString = ""
        // a -> range (1,0), replacementString = a
        kRange = range
        kReplacementText = text
        
        if text == String(kMentionSymbol) {
            hlMentionSearchInfo.kRange = NSRange(location: range.location, length:text.count)
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            return true
        }
        
        // remove when editing word
        if let mentionInfos = mentionInfoIsValidInRange(range: range, replacementString: text) {
            kMentionInfoRemoved = true
            if let mentionInfo = mentionInfos.first,
                (text.isEmpty || text.count == 1) && mentionInfos.count == 1 {
                
                if (range.location >= mentionInfo.kRange.location) && (range.location < mentionInfo.kRange.location + mentionInfo.kRange.length) {
                    guard let textRange = textRangeFromLocation(start: mentionInfo.kRange.location, end: mentionInfo.kRange.location + mentionInfo.kRange.length) else { return false}
                    hlRemoveMentionInfo(mention: mentionInfo)
                    kRange = mentionInfo.kRange
                    kReplacementText = ""
                    self.replace(textRange, withText: text)
                    return false
                }
                
                for mentionInfo in mentionInfos {
                    hlRemoveMentionInfo(mention: mentionInfo)
                }
                kMentionCurrentCursorLocation = range.location - range.length
                
                kMentionCurrentCursorLocation = mentionInfo.kRange.location + text.count
                if text.isValidCharacterBackSpace() {
                    kMentionCurrentCursorLocation -= range.length
                }
                return false
            }
            
            // mention info have more than one and replacementStri@ng count > 1
            for mentionInfo in mentionInfos {
                hlRemoveMentionInfo(mention: mentionInfo)
            }
            kMentionCurrentCursorLocation = range.location - range.length
            return false
        }
        return true
    }
    
    func hlTextViewDidChange(_ textView: UITextView) {
        if !kTextViewDidChange {
            hlAttributeStringMentionInfo()
            hlSetTypingAttributes()
            kTextViewDidChange = true
            return
        }
        
        let currentCursorLocation = getCurrentCursorLocation()
        if kUndoText.count != text.count && !kMentionInfos.isEmpty {
            hlUpdateMentionLocation()
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            hlUpdateMentionLocation()
            hlMentionInfosTableView.removeAll()
        }
        if let kListMentionInfos = kListMentionInfos {
            if let mentionInfos = hlHandleSearch(from: kListMentionInfos) {
                hlMentionInfosTableView = mentionInfos
                hlTableView?.reloadData()
                return
            }
        } else {
            if let searchText = hlHandleSearchString() {
                if let delegate = hlDelegate {
                    delegate.hlMentionsTextViewCallBackFromSearch?(self, searchText: searchText)
                    return
                }
            }
        }
        
        kLastCursorLocation = currentCursorLocation
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: currentCursorLocation)
        kUndoText = text
    }
}

/*
extension HLMentionsTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // backspace data -> range (0,1), replacementString = ""
        // a -> range (1,0), replacementString = a
        kRange = range
        kReplacementText = text
        
        if text == String(kMentionSymbol) {
            hlMentionSearchInfo.kRange = NSRange(location: range.location, length:text.count)
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            return true
        }

        // remove when editing word
        if let mentionInfos = mentionInfoIsValidInRange(range: range, replacementString: text) {
            kMentionInfoRemoved = true
            if let mentionInfo = mentionInfos.first,
                (text.isEmpty || text.count == 1) && mentionInfos.count == 1 {
                
                if (range.location >= mentionInfo.kRange.location) && (range.location < mentionInfo.kRange.location + mentionInfo.kRange.length) {
                    guard let textRange = textRangeFromLocation(start: mentionInfo.kRange.location, end: mentionInfo.kRange.location + mentionInfo.kRange.length) else { return false}
                    hlRemoveMentionInfo(mention: mentionInfo)
                    kRange = mentionInfo.kRange
                    kReplacementText = ""
                    self.replace(textRange, withText: text)
                    return false
                }

                for mentionInfo in mentionInfos {
                    hlRemoveMentionInfo(mention: mentionInfo)
                }
                kMentionCurrentCursorLocation = range.location - range.length
//                removeMentionInfoAndUpdateLocation(mentionInfo: mentionInfo)

                
                
                kMentionCurrentCursorLocation = mentionInfo.kRange.location + text.count
                if text.isValidCharacterBackSpace() {
                    kMentionCurrentCursorLocation -= range.length
                }
                return false
            }
            
            // mention info have more than one and replacementStri@ng count > 1
            for mentionInfo in mentionInfos {
                hlRemoveMentionInfo(mention: mentionInfo)
            }
            kMentionCurrentCursorLocation = range.location - range.length
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {

        if !kTextViewDidChange {
            kTextViewDidChange = true
            return
        }
        
        let currentCursorLocation = getCurrentCursorLocation()
        if kUndoText.count != text.count && !kMentionInfos.isEmpty {
            hlUpdateMentionLocation()
        } else if self.kReplacementText == " " && self.kRange.length == 0 {
            hlUpdateMentionLocation()
        } else if let kListMentionInfos = kListMentionInfos {
            if let mentionInfos = hlHandleSearch(from: kListMentionInfos) {
                hlMentionInfosTableView = mentionInfos
                hlTableView?.reloadData()
                return
            }
        } else {
            if let searchText = hlHandleSearchString() {
                if let delegate = hlDelegate {
                    delegate.hlMentionsTextViewCallBackFromSearch(self, searchText: searchText)
                    return
                }
            }
        }
        
        kLastCursorLocation = currentCursorLocation
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: currentCursorLocation)
        kUndoText = text
    }
}
*/
