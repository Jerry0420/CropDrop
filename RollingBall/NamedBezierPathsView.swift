//
//  NamedBezierPathsView.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/26.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView
{
    var bezierPaths = [String:UIBezierPath]() { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
}
