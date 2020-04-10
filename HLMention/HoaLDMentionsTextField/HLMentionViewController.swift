//
//  ViewController.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

class HLMentionViewController: UIViewController {
    
    @IBOutlet weak var mentionTextView: HLMentionsTextView!
//    @IBOutlet weak var tbListUserTag: UITableView!
    
    @IBOutlet weak var postBtn: UIButton!
    let text = "::00:: đẹp trai ::04:: đẹp gái"
    let kMentionInfos: [HLMentionInfo] = [HLMentionInfo("00", "Hoa"), HLMentionInfo("01", "Vuong Khac Duy"), HLMentionInfo("02", "Dương"),
                                        HLMentionInfo("03", "Nguyễn Đoàn Nguyên An"), HLMentionInfo("04", "Nguyễn Kiều Vy"), HLMentionInfo("05", "Nguyễn Duy Ngân"),
                                        HLMentionInfo("06", "Donald Trump"), HLMentionInfo("07", "Hoà cute phô mai que")]
    
    //tableview data
//    var hlMentionInfosTableView: [HLMentionInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mentionTextView.hlDelegate = self
        mentionTextView.delegate = self
        mentionTextView.kListMentionInfos = kMentionInfos
//        mentionTextView.HLtext = text
//        mentionTextView.kMentionInfos = getDemoData()
        mentionTextView.hlResetData()
    }
    
    func getDemoData() -> [HLMentionInfo] {
        let HoaLD = HLMentionInfo("00", "Hoa")
        HoaLD.kRange = NSRange(location: 0, length: 4)
        
        let VyNK = HLMentionInfo("04", "Nguyễn Kiều Vy")
        VyNK.kRange = NSRange(location: 14, length: 15)
        
        return [HoaLD, VyNK]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mentionTextView.becomeFirstResponder()
    }
    @IBAction func postTouched(_ sender: UIButton) {
       let object = mentionTextView.getTextAndMentionInfos()
        let string = "\(object?.attributeText.string) (\(object?.mentionInfos.count)"
        postBtn.setTitle(string, for: UIControl.State.normal)
    }
    
}
//  MARK: - HLMentionsTextViewDelegate

extension HLMentionViewController: HLMentionsTextViewDelegate {
    func hlMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?) {
        
    }
    
    /*
    func hlMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?) {
        if let mentionInfos = mentionInfos {
//            hlMentionInfosTableView = mentionInfos
//            tbListUserTag.reloadData()
        }
    }
    */
    
    func hlMentionsTextViewCallBackFromSearch(_ textView: HLMentionsTextView, searchText: String) {
        postBtn.setTitle(searchText, for: UIControl.State.normal)
    }
}

extension HLMentionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return mentionTextView.hlTextView(textView, shouldChangeTextIn: range, replacementText: text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        mentionTextView.hlTextViewDidChange(textView)
    }
}
