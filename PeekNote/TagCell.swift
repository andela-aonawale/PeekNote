//
//  TagCell.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/25/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var maximumWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        tagName.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        layer.cornerRadius = 4
        maximumWidth.constant = UIScreen.mainScreen().bounds.width - 8 * 2 - 8 * 2
    }

}
