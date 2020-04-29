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
    @objc optional func hlMentionsTextViewCallBackFromSearch(_ textView: HLMentionsTextView, searchText: String?)
    
    /* if you want anythings just add from UITextView delegate*/
}

class HLMentionsTextView: UITextView {
    
    /* TableView object*/
    @IBOutlet weak var hlTableView: UITableView?
    @IBOutlet weak var hlTableViewDataSource: UITableViewDataSource?
    @IBOutlet weak var hlTableViewDelegate: UITableViewDelegate?
    @IBOutlet weak var hlTableViewHeightConstaint: NSLayoutConstraint!
    
    private var hlTextViewDidChange = true
    
    var hlStore = HLInstant()
    
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
    
    weak var hlDelegate: HLMentionsTextViewDelegate?
    
    
    //full all data or data need to setup
    var hlTypingAttributes: Dictionary<String, Any> = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.darkText,
                                                      NSAttributedString.Key.paragraphStyle.rawValue: NSParagraphStyle(),
                                                      NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
    
//    var hlFont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
//    var hlTextColor : UIColor = UIColor.darkText
    
    private var hlCurrentCursorLocation: Int = 0 // after edit or doing text change -> set this

    // don't touch
    private var kMentionInfoInsertInfrontRange: NSRange?
    private var hlUndoText = ""
    
    func getTextAndMentionInfos() -> (attributeText: NSAttributedString, mentionInfos: [HLMentionInfo])? {
        let mentionInfos = hlStore.hlMentionInfos
        
        let mentionAttributeText = NSMutableAttributedString(attributedString: attributedText)
        mentionAttributeText.hlAttributeStringRemoveAttributes()
        for mentionInfo in mentionInfos {
            mentionAttributeText.replaceCharacters(in: mentionInfo.kRange, with: mentionInfo.getTagID())
            hlUpdateMentionInfosRange(range: mentionInfo.kRange, insertTextCount: mentionInfo.getTagID().count)
            print(mentionAttributeText.string)
        }
        return(mentionAttributeText, mentionInfos)
    }
    
    override func awakeFromNib() {
        hlResetData()
        hlAttributeStringMentionInfo()
        hlInitTextView()
        hlInitTableView()
    }
    
    func hlInitTextView() {
        returnKeyType = .default
    }
    
    func hlInitTableView() {
        guard let tableView = hlTableView else { return }
        tableView.register(UINib(nibName: String(describing: HLMentionTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: HLMentionTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = hlStore.hlTableViewBackgroundColor
        
        let layer: CALayer = tableView.layer
        layer.borderWidth = hlStore.hlTaBleViewBorderWidth
        layer.borderColor = hlStore.hlTaBleViewBorderColor
        layer.cornerRadius = hlStore.hlTaBleViewCornerRadius
        layer.masksToBounds = hlStore.hlTaBleViewMasksToBounds
        
        if hlTableViewHeightConstaint.constant > 0 {
            if hlTableViewHeightConstaint.constant <= hlStore.hlTableViewHeight {
                hlStore.hlTableViewHeight = hlTableViewHeightConstaint.constant
            }
        }
    }
    
    func hlResetData() {
        hlSetTypingAttributes()
        hlSetDisplayText()
        hlAttributeStringMentionInfo()
        hlStore.hlMentionSearchInfo.removeAll()
        hlMentionInfosTableView.removeAll()
        hlInitTableView()
    }
    
    func hlRemoveData() {
        hlStore.hlMentionSearchInfo.removeAll()
        hlStore.hlListMentionInfos?.removeAll()
        hlStore.hlMentionInfos.removeAll()
        hlMentionInfosTableView.removeAll()
    }
    
    func hlSetDisplayText() {
        if hlStore.hlText.isEmpty { return }
        var mentionText = hlStore.hlText
        for mentionInfo in hlStore.hlMentionInfos {
            let findString = mentionInfo.getTagID()
            let replaceString = mentionInfo.kName
            if mentionInfo.kRange.length == 0 && mentionInfo.kRange.location == 0 {
                mentionInfo.kRange = NSMakeRange(mentionText.indexOfString(text: findString), replaceString.count)
            }
            mentionText = mentionText.replacingOccurrences(of: findString, with: replaceString)
        }
        hlStore.hlText = mentionText
    }
    
    func hlAttributeStringMentionInfo() {
        if hlStore.hlText.isEmpty {
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
            attributedText.hlAttributeStringRemoveAttributes()
            attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: hlStore.hlMentionInfos),
                                                         highLightColor: hlStore.hlHighlightColor)
            self.attributedText = attributedText
        } else {
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: hlStore.hlText,
                                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkText,
                                                                                      NSAttributedString.Key.paragraphStyle: NSParagraphStyle(),
                                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
            attributedText.hlAttributeStringRemoveAttributes()
            attributedText.hlAttributeStringInsertRanges(ranges: hlAttributeRangesFrom(mentionInfos: hlStore.hlMentionInfos),
                                                         highLightColor: hlStore.hlHighlightColor)
            self.attributedText = attributedText
            hlStore.hlText = ""
        }
    }
    
    func hlHandleSearch(from kMentionInfos: [HLMentionInfo], with word: String) -> [HLMentionInfo]? {
        var currentWord = word
        if currentWord.count >= (String(hlStore.hlMentionSymbol).count + hlStore.hlHowManyCharacterBeginSearch) {
            if currentWord.stringFrom(start: 0, end: 1) == String(hlStore.hlMentionSymbol) {
                hlStore.hlMentionSearchInfo.kRange = NSMakeRange(getCurrentWordLocation(), currentWord.count)
                hlStore.hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                
                if !hlStore.hlMentionSearchInfo.kText.isEmpty {
                    return self.mentionInfosSearchFrom(hlStore.hlMentionSearchInfo.kText,from: kMentionInfos)
                }
                
                for mentionInfo in kMentionInfos {
                    if (mentionInfo.kRange.location + mentionInfo.kRange.length == hlStore.hlMentionSearchInfo.kRange.location)
                        || mentionInfo.kName == hlStore.hlMentionSearchInfo.kText {
                        return nil
                    }
                }
                
                return self.mentionInfosSearchFrom(hlStore.hlMentionSearchInfo.kText,from: kMentionInfos)
            }
        }
        return nil
    }

    func hlHandleSearchString(with word: String) -> String? {
        var currentWord = word
        if currentWord.count >= (String(hlStore.hlMentionSymbol).count + hlStore.hlHowManyCharacterBeginSearch) {
            if currentWord.stringFrom(start: 0, end: 1) == String(hlStore.hlMentionSymbol) {
                hlStore.hlMentionSearchInfo.kRange = NSMakeRange(getCurrentWordLocation(), currentWord.count)
                hlStore.hlMentionSearchInfo.kText = String(currentWord.dropFirst())
                return hlStore.hlMentionSearchInfo.kText
            }
        }
        return nil
    }
    
    func rangeTextInsertInfrontMention(range: NSRange, replacementString: String) -> NSRange? {
        for mentionInfo in hlStore.hlMentionInfos {
            if range.location == mentionInfo.kRange.location {
                return NSMakeRange(range.location, replacementString.count)
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
        
        let insertString = mentionInfo.kName
        
        let mention = mentionInfo.copy() as! HLMentionInfo
        mention.kRange = NSMakeRange(range.location, insertString.count)
        
        hlUpdateMentionInfosRange(range: NSMakeRange(range.location, range.length), insertTextCount: insertString.count)
        hlStore.hlMentionInfos.append(mention)
        
        hlTextViewDidChange = false
        self.replace(textRange, withText: insertString)
        hlSetCurrentCursorLocation(index: range.location + insertString.count)
    }
    
    func hlInsertMentionInfo(mentionInfo: HLMentionInfo,at textRange: UITextRange) {
        let range = hlSelectedRange(from: textRange)
        let insertString = mentionInfo.kName
        
        let mention = mentionInfo.copy() as! HLMentionInfo
        mention.kRange = NSMakeRange(range.location, insertString.count)
        
        hlUpdateMentionInfosRange(range: NSMakeRange(range.location, range.length), insertTextCount: insertString.count)
        hlStore.hlMentionInfos.append(mention)
        
        hlTextViewDidChange = false
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
        hlUpdateMentionInfosRange(range: hlStore.hlRange, insertTextCount: hlStore.hlReplacementText.count)
    }
    
    func hlUpdateMentionInfosRange(range: NSRange, insertTextCount: Int) {
        if hlStore.hlMentionInfos.isEmpty {
            return
        }
        if range.length > 0 {
            hlUpdatekMentionInfosRemoveRange(range: range)
        }
        
        if insertTextCount > 0 {
            hlUpdatekMentionInfosInsertRange(range: NSMakeRange(range.location, insertTextCount))
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
        
        // remove when editing word
        if let mentionInfos = mentionInfoIsValidInRange(range: range, replacementString: text) {
            // detect new range location remove string to replace
            var newRange = NSMakeRange(range.location, range.length)
            for mentionInfo in mentionInfos {
                if newRange.location > mentionInfo.kRange.location {
                    newRange.length = newRange.length + (newRange.location - mentionInfo.kRange.location)
                    newRange.location = mentionInfo.kRange.location
                }
                
                if newRange.location + newRange.length < mentionInfo.kRange.location + mentionInfo.kRange.length {
                    newRange.length = (mentionInfo.kRange.location + mentionInfo.kRange.length) - newRange.location
                }
            }
            
            //            hlStore.kRange = mentionInfo.kRange
            hlStore.hlReplacementText = ""
            
            // mention info have more than one and replacementString count > 1
            for mentionInfo in mentionInfos {
                hlRemoveMentionInfo(mention: mentionInfo)
            }
            hlTextViewDidChange = false
            hlCurrentCursorLocation = newRange.location + text.count
            if let textRange = textRangeFromLocation(start: newRange.location, end: newRange.location + newRange.length) {
                self.replace(textRange, withText: text)
            }
            return false
        }
        
        hlStore.hlRange = range
        hlStore.hlReplacementText = text
        hlCurrentCursorLocation = range.location + text.count
        if text == String(hlStore.hlMentionSymbol) {
            hlStore.hlMentionSearchInfo.kRange = NSMakeRange(range.location, text.count)
        } else if hlStore.hlReplacementText == " " && hlStore.hlRange.length == 0 {
            return true
        }
        
        return true
    }
    
    func hlTextViewDidChange(_ textView: UITextView) {
        
        test()
        if !hlTextViewDidChange {
            hlAttributeStringMentionInfo()
            hlSetTypingAttributes()
            hlSetCurrentCursorLocation(index: hlCurrentCursorLocation)
            hlTextViewDidChange = true
            return
        }
        
        if hlUndoText.count != text.count && !hlStore.hlMentionInfos.isEmpty {
            hlUpdateMentionLocation()
            hlAttributeStringMentionInfo()
        } else if hlStore.hlReplacementText == " " && hlStore.hlRange.length == 0 {
            hlUpdateMentionLocation()
            hlMentionInfosTableView.removeAll()
        }
        
        let currentWord = self.currentWord()
        if let kListMentionInfos = hlStore.hlListMentionInfos {
            if let mentionInfos = hlHandleSearch(from: kListMentionInfos,with: currentWord) {
                hlMentionInfosTableView = mentionInfos
            } else {
                hlMentionInfosTableView.removeAll()
            }
            hlTableView?.reloadData()
            return
        }
        
        if let delegate = hlDelegate {
            if let searchText = hlHandleSearchString(with: currentWord), hlStore.hlReplacementText != " " {
                delegate.hlMentionsTextViewCallBackFromSearch?(self, searchText: searchText)
                return
            } else {
                delegate.hlMentionsTextViewCallBackFromSearch?(self, searchText: nil)
            }
        }
        
        hlAttributeStringMentionInfo()
        hlSetTypingAttributes()
        hlSetCurrentCursorLocation(index: hlCurrentCursorLocation)
        hlUndoText = text
    }
    
    func test() {
        let attributedText = NSAttributedString(string: "Hello, playground", attributes: [
          .foregroundColor: UIColor.red,
          .backgroundColor: UIColor.green,
          .ligature: 1,
          .strikethroughStyle: 1
        ])

        // retrieve attributes
        let attributes = attributedText.attributes(at: 0, effectiveRange: nil)

        // iterate each attribute
        for attr in attributes {
          print(attr.key, attr.value)
        }
    }
}
