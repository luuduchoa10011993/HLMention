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
        if hlStore.hlMentionInfosTableView.isEmpty {
            hlHideTableView()
        } else {
            hlShowTableView()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hlStore.hlMentionInfosTableView.count > hlStore.hlTableViewMax {
            return hlStore.hlTableViewMax
        }
        return hlStore.hlMentionInfosTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HLMentionTableViewCell.self), for: indexPath) as! HLMentionTableViewCell
        cell.display(hlStore.hlMentionInfosTableView[indexPath.item])
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
            hlStore.hlMentionInfosTableView.removeAll()
        } else {
            hlStore.hlMentionInfosTableView = hlStore.hlMentionInfos
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
        hlTableViewHeightConstaint.constant = hlStore.hlTableViewHeight
    }
}
