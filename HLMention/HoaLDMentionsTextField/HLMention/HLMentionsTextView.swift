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
    
    var hlStore = HLInstant()
    
    /* TableView object*/
    @IBOutlet weak var hlTableView: UITableView?
    @IBOutlet weak var hlTableViewDataSource: UITableViewDataSource?
    @IBOutlet weak var hlTableViewDelegate: UITableViewDelegate?
    @IBOutlet weak var hlTableViewHeightConstaint: NSLayoutConstraint!

    
    var hlMentionInfosTableView:[HLMentionInfo] {
        get {
            return hlStore.hlMentionInfosTableView
        }
        set {
            hlStore.hlMentionInfosTableView = newValue
            if let tableView = hlTableView {
                tableView.reloadData()
            }
        }
    }
    var hlText: String {
        get {
            return hlStore.hlText
        }
        set {
            hlStore.hlText = newValue
        }
    }
    
    weak var hlDelegate: HLMentionsTextViewDelegate?
    
    //HL Search offline data
    var kListMentionInfos: [HLMentionInfo]?
    
    //full all data or data need to setup
    var kMentionSymbol : Character {
        get {
            return hlStore.hlMentionSymbol
        }
        set {
            hlStore.hlMentionSymbol = newValue
        }
    }
    

    var hlTypingAttributes: Dictionary<String, Any> = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.darkText,
                                                      NSAttributedString.Key.paragraphStyle.rawValue: NSParagraphStyle(),
                                                      NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
    
//    var hlFont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
//    var hlTextColor : UIColor = UIColor.darkText
    
    
    
    // search
    var hlMentionSearchInfo = HLMentionSearchInfo()
    
    private var kLastCursorLocation = 0
    private var kMentionCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this
    private var kMentionInfoRemoved: Bool = false

    // don't touch
    private var kMentionInfoInsertInfrontRange: NSRange?
    private var kUndoText = ""
    

    var kTextViewDidChange = true
    
//    var kMentionLastEditLocation: Int = 0
    
    func getTextAndMentionInfos() -> (attributeText: NSAttributedString, mentionInfos: [HLMentionInfo])? {
        
        
        var mentionInfos = [HLMentionInfo]()
        for mentionInfo in hlStore.hlMentionInfos {
           if mentionInfo.kAct == .at {
                mentionInfos.append(mentionInfo)
            }
        }
        
        let mentionAttributeText = NSMutableAttributedString(attributedString: attributedText)
        mentionAttributeText.hlAttributeStringRemoveAttributes()
        for mentionInfo in hlStore.hlMentionInfos {
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
            hlStore.hlTableViewHeight = hlTableViewHeightConstaint.constant
        }
    }
    
    func hlResetData() {
        hlSetTypingAttributes()
        hlSetDisplayText()
        hlAttributeStringMentionInfo()
        hlMentionSearchInfo.removeAll()
        hlMentionInfosTableView.removeAll()
    }
    
    func hlSetDisplayText() {
        var mentionText = hlText
        for mentionInfo in hlStore.hlMentionInfos {
            let findString = mentionInfo.getTagID()
            let replaceString = "\(kMentionSymbol)\(mentionInfo.kName)"
            if mentionInfo.kRange.length == 0 && mentionInfo.kRange.location == 0 {
                mentionInfo.kRange = NSRange(location: mentionText.indexOfString(text: findString), length: replaceString.count)
            }
            mentionText = mentionText.replacingOccurrences(of: findString, with: replaceString)
        }
        hlText = mentionText
    }
    
    func hlGetMentionInfoText() -> String{
        guard var mentionText = text else {
            return ""
        }
        for mentionInfo in hlStore.hlMentionInfos {
            mentionText = mentionText.replacingOccurrences(of: "\(kMentionSymbol)\(mentionInfo.kName)", with: mentionInfo.getTagID())
        }
        return mentionText
    }
    
    func hlAttributeStringMentionInfo() {
        if hlText.isEmpty {
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
            attributedText.hlAttributeStringRemoveAttributes()
            attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: hlStore.hlMentionInfos),
                                                         highLightColor: hlStore.hlHighlightColor)
            self.attributedText = attributedText
        } else {
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: hlText,
                                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkText,
                                                                                      NSAttributedString.Key.paragraphStyle: NSParagraphStyle(),
                                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
            attributedText.hlAttributeStringRemoveAttributes()
            attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: hlStore.hlMentionInfos),
                                                         highLightColor: hlStore.hlHighlightColor)
            self.attributedText = attributedText
            hlText = ""
        }
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
        for mentionInfo in hlStore.hlMentionInfos {
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
        hlStore.hlMentionInfos.append(mention)
        
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
        guard let mentionObject = HLMentionInfo.mentionInfoFromArray(mentionInfos: hlStore.hlMentionInfos, mentionInfo: mention) else { return }
        hlStore.hlMentionInfos.remove(at: mentionObject.mentionIndex)
    }
    
    func hlUpdateMentionLocation() {
        hlUpdateMentionInfosRange(range: hlStore.kRange, insertTextCount: hlStore.kReplacementText.count)
    }
    
    func hlUpdateMentionInfosRange(range: NSRange, insertTextCount: Int) {
        if hlStore.hlMentionInfos.isEmpty {
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
        for mention in hlStore.hlMentionInfos {
            if (range.location > mention.kRange.location && range.location < mention.kRange.location + mention.kRange.length)
            || range.location <= mention.kRange.location {
                mention.kRange.location += range.length
            }
        }
    }
    
    func hlUpdatekMentionInfosRemoveRange(range: NSRange) {
        for mention in hlStore.hlMentionInfos {
            if mention.kRange.location > range.location {
                mention.kRange.location -= range.length
            }
        }
    }
    
    func hlTextView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // backspace data -> range (0,1), replacementString = ""
        // a -> range (1,0), replacementString = a
        hlStore.kRange = range
        hlStore.kReplacementText = text
        
        if text == String(kMentionSymbol) {
            hlMentionSearchInfo.kRange = NSRange(location: range.location, length:text.count)
        } else if hlStore.kReplacementText == " " && hlStore.kRange.length == 0 {
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
                    hlStore.kRange = mentionInfo.kRange
                    hlStore.kReplacementText = ""
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
        if (textView.attributedText.string.count == hlStore.kRange.location - hlStore.kReplacementText.count)
            && (textView.attributedText.string.count <= self.getCurrentCursorLocation()) {
            return
        }
        
        if !kTextViewDidChange {
            hlAttributeStringMentionInfo()
            hlSetTypingAttributes()
            kTextViewDidChange = true
            return
        }
        
        let currentCursorLocation = getCurrentCursorLocation()
        if kUndoText.count != text.count && !hlStore.hlMentionInfos.isEmpty {
            hlUpdateMentionLocation()
        } else if hlStore.kReplacementText == " " && hlStore.kRange.length == 0 {
            hlUpdateMentionLocation()
            hlMentionInfosTableView.removeAll()
        }
        if let kListMentionInfos = kListMentionInfos {
            if let mentionInfos = hlHandleSearch(from: kListMentionInfos) {
                hlMentionInfosTableView = mentionInfos
                hlTableView?.reloadData()
                return
            }
        }
        if let searchText = hlHandleSearchString(), hlStore.kReplacementText != " " {
            if let delegate = hlDelegate {
                delegate.hlMentionsTextViewCallBackFromSearch?(self, searchText: searchText)
                return
            }
        }
        
        kLastCursorLocation = currentCursorLocation
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: currentCursorLocation)
        kUndoText = text
    }
}
