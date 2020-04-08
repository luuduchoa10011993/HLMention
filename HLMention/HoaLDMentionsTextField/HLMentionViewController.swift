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
    @IBOutlet weak var tbListUserTag: UITableView!
    
    @IBOutlet weak var postBtn: UIButton!
    let text = "::00:: đẹp trai ::04:: đẹp gái"
    let kMentionInfos: [HLMentionInfo] = [HLMentionInfo("00", "Hoa"), HLMentionInfo("01", "Vuong Khac Duy"), HLMentionInfo("02", "Dương"),
                                        HLMentionInfo("03", "Nguyễn Đoàn Nguyên An"), HLMentionInfo("04", "Nguyễn Kiều Vy"), HLMentionInfo("05", "Nguyễn Duy Ngân"),
                                        HLMentionInfo("06", "Donald Trump"), HLMentionInfo("07", "Hoà cute phô mai que")]
    
    //tableview data
    var kMentionInfosTableView: [HLMentionInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbListUserTag.tableFooterView = UIView()
        
        mentionTextView.HLdelegate = self
        mentionTextView.kListMentionInfos = kMentionInfos
        mentionTextView.HLtext = text
        mentionTextView.kMentionInfos = getDemoData()
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
    
    func refreshMentionList(_ removeAll: Bool = true) {
        if removeAll {
            kMentionInfosTableView.removeAll()
        } else {
            kMentionInfosTableView = kMentionInfos
        }
        tbListUserTag.reloadData()
    }
    @IBAction func postTouched(_ sender: UIButton) {
       let object = mentionTextView.getTextAndMentionInfos()
        let string = "\(object?.text) (\(object?.mentionInfos.count)"
        postBtn.setTitle(string, for: UIControl.State.normal)
    }
    
}

//  MARK: - UITableView Delegate - DataSource
extension HLMentionViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isHidden = kMentionInfosTableView.count == 0 ? true : false
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if kMentionInfosTableView.count > 5 {
            return 5
        }
        return kMentionInfosTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HLMentionTableViewCell.self), for: indexPath) as! HLMentionTableViewCell
        cell.display(kMentionInfosTableView[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell:HLMentionTableViewCell = tableView.cellForRow(at: indexPath) as? HLMentionTableViewCell else { return }
        let mentionInfo = cell.getMentionInfo()
        mentionTextView.hlInsertMentionInfoWhenSearch(mentionInfo: mentionInfo.copyObject())
        refreshMentionList()
    }
}

//  MARK: - HLMentionsTextViewDelegate

extension HLMentionViewController: HLMentionsTextViewDelegate {
    func HLMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfos: [HLMentionInfo]?) {
        if let mentionInfos = mentionInfos {
            kMentionInfosTableView = mentionInfos
            tbListUserTag.reloadData()
        }
    }
    
    func HLMentionsTextViewMentionInfos(_ textView: HLMentionsTextView, mentionInfoText: String, mentionInfos: [HLMentionInfo]?) {
        
    }

}
