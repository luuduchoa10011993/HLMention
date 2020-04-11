//
//  HLMention+UITableView.swift
//  HLMention
//
//  Created by HoaLD on 4/8/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit


//  MARK: - UITableView Delegate - DataSource
extension HLMentionsTextView: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if _hlMentionInfosTableView.isEmpty {
            hlHideTableView()
        } else {
            hlShowTableView()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _hlMentionInfosTableView.count > 5 {
            return 5
        }
        return _hlMentionInfosTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HLMentionTableViewCell.self), for: indexPath) as! HLMentionTableViewCell
        cell.display(_hlMentionInfosTableView[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell:HLMentionTableViewCell = tableView.cellForRow(at: indexPath) as? HLMentionTableViewCell else { return }
        let mentionInfo = cell.getMentionInfo()
        hlInsertMentionInfo(mentionInfo: mentionInfo.copyObject(), at: self.hlMentionSearchInfo.kRange)
        refreshMentionList()
    }
    
    func refreshMentionList(_ removeAll: Bool = true) {
        if removeAll {
            _hlMentionInfosTableView.removeAll()
        } else {
            _hlMentionInfosTableView = kMentionInfos
        }
        if let tableView = hlTableView {
            tableView.reloadData()
        }
    }
    
    func hlHideTableView() {
        guard let tableView = hlTableView else { return }
        tableView.isHidden = true
        hlTableViewHeightConstaint.constant = 0
    }
    
    func hlShowTableView() {
        guard let tableView = hlTableView else { return }
        tableView.isHidden = false
        hlTableViewHeightConstaint.constant = hlTableViewHeight
    }
}