//
//  NameTableViewCell.swift
//  HLMention
//
//  Created by Lưu Đức Hoà on 4/2/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    @IBOutlet weak var lbNameUser: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func display(_ userInfo: HLMentionInfo) {
        self.lbNameUser.text = userInfo.getDisplayName()
    }
}
