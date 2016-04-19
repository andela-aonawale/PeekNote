//
//  PatternImageView.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 4/17/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import UIKit

final class PatternView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .backgroundColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
