//
//  HLMentionImageCollectionViewCell.swift
//  HLMention
//
//  Created by HoaLD on 10/21/20.
//  Copyright © 2020 Luu Duc Hoa. All rights reserved.
//

import UIKit

protocol HLMentionImageCollectionViewCellDelegate {
    func removeTap(cell: HLMentionImageCollectionViewCell)
}

class HLMentionImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hlMentionImage: UIImageView!
    
    var delegate: HLMentionImageCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func removeTap(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.removeTap(cell: self)
        }
    }
    
}
