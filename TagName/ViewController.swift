//
//  ViewController.swift
//  TagName
//
//  Created by Mojave on 3/17/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Tagging
import SZMentionsSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var mentionsTextField: HoaLDMentionsTextField!
    @IBOutlet weak var tbListUserTag: UITableView!
    
    let kMentionInfos: [MentionInfo] = [MentionInfo("00", "Hoa"), MentionInfo("01", "Vuong Khac Duy"), MentionInfo("02", "Dương"),
                               MentionInfo("03", "Nguyễn Đoàn Nguyên An"), MentionInfo("04", "Nguyễn Kiều Vy"), MentionInfo("05", "Nguyễn Duy Ngân"),
                               MentionInfo("06", "Donald Trump"), MentionInfo("07", "Hoà cute phô mai que")]
    var range: NSRange = _NSRange()
    var replacementString: String = ""
    var arrayNameDidChangeAttribute:[String] = []
    
    let disposeBag = DisposeBag()
    var stringNeedReplace = ""
    var textChange = ""
    var text  = ""
    
    //tableview data
    var kMentionInfosTableView: [MentionInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tbListUserTag.tableFooterView = UIView()
        mentionsTextField.kListMentionInfos = kMentionInfos
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mentionsTextField.becomeFirstResponder()
    }
    
    func refreshMentionList(_ removeAll: Bool = true) {
        if removeAll {
            kMentionInfosTableView.removeAll()
        } else {
            kMentionInfosTableView = kMentionInfos
        }
        tbListUserTag.reloadData()
    }
    
}

//  MARK: - UITableView Delegate - DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NameTableViewCell.self), for: indexPath) as! NameTableViewCell
        cell.display(kMentionInfosTableView[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mentionInfo = kMentionInfosTableView[indexPath.row]
        mentionsTextField.insertMentionInfoWhenSearching(mentionInfo: mentionInfo.copyObject())
        refreshMentionList()
    }
}

//  MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.range = range
        self.replacementString = string
        
        let mentionsTextFieldData = mentionsTextField.dataTextField(range: range, replacementString: string)
        kMentionInfosTableView = mentionsTextFieldData.mentionInfos ?? [MentionInfo]()
        tbListUserTag.reloadData()
        return mentionsTextFieldData.shouldChangeCharacters
    }
}
