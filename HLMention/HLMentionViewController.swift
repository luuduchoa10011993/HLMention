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
        
        kMentionInfos[0].kImage = UIImage(named: "image01")
        kMentionInfos[3].kImage = UIImage(named: "image02")
        
        
        mentionTextView.hlDelegate = self
        mentionTextView.delegate = self
        mentionTextView.hlStore.hlListMentionInfos = kMentionInfos
        mentionTextView.hlStore.hlText = text
        mentionTextView.hlStore.hlMentionInfos = getDemoData()
        mentionTextView.hlStore.hlTableViewBackgroundColor = UIColor.white
        mentionTextView.hlResetData()
    }
    
    func getDemoData() -> [HLMentionInfo] {
        let HoaLD = HLMentionInfo("00", "Hoa")
        HoaLD.kRange = NSMakeRange(0, HoaLD.kName.count)
        
        let VyNK = HLMentionInfo("04", "Nguyễn Kiều Vy")
        VyNK.kRange = NSMakeRange(13, VyNK.kName.count)
        
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
    
    func hlMentionsTextViewCallBackFromSearch(_ textView: HLMentionsTextView, searchText: String?) {
        if let searchText = searchText {
            postBtn.setTitle(searchText, for: UIControl.State.normal)
        } else {
            postBtn.setTitle("Post", for: UIControl.State.normal)
        }
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
