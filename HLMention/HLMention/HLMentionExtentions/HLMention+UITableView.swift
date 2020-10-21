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
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if hlStore.hlMentionInfosTableView.isEmpty {
            hlHideTableView()
        } else {
            hlShowTableView()
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hlStore.hlMentionInfosTableView.count > hlStore.hlTableViewMax {
            return hlStore.hlTableViewMax
        }
        return hlStore.hlMentionInfosTableView.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HLMentionTableViewCell.self), for: indexPath) as! HLMentionTableViewCell
        cell.display(hlStore.hlMentionInfosTableView[indexPath.item])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell:HLMentionTableViewCell = tableView.cellForRow(at: indexPath) as? HLMentionTableViewCell else { return }
        let mentionInfo = cell.getMentionInfo()
        hlInsertMentionInfo(mentionInfo: mentionInfo.copyObject(), at: self.hlStore.hlMentionSearchInfo.kRange)
        hlStore.hlMentionSearchInfo.removeAll()
        self.refreshMentionList()
        self.hlHideTableView()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = hlStore.hlTableViewCellHeight{
            return height
        }
        return UITableView.automaticDimension
        
    }
    
    public func refreshMentionList(_ removeAll: Bool = true) {
        if removeAll {
            hlStore.hlMentionInfosTableView.removeAll()
        } else {
            hlStore.hlMentionInfosTableView = hlStore.hlMentionInfos
        }
        if let tableView = hlTableView {
            tableView.reloadData()
        }
    }
    
    public func hlHideTableView() {
        guard let tableView = hlTableView else { return }
        tableView.isHidden = true
        hlTableViewHeightConstaint.constant = 0
    }
    
    public func hlShowTableView() {
        guard let tableView = hlTableView else { return }
        tableView.isHidden = false
        hlTableViewHeightConstaint.constant = hlStore.hlTableViewHeight
    }
}
