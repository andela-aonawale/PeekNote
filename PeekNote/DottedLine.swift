//
//  DottedLine.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 3/25/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class DottedLine: UIView {
    
    @IBInspectable var lineWidth: CGFloat = 0
    @IBInspectable var lineColor: UIColor = UIColor.blackColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: frame.origin.x, y: frame.height/2))
        path.addLineToPoint(CGPoint(x: frame.width, y: frame.height/2))
        path.lineWidth = lineWidth
        lineColor.setStroke()
        let dashes: [CGFloat] = [path.lineWidth * 0, path.lineWidth * 2]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.Round
        path.stroke()
    }
}
