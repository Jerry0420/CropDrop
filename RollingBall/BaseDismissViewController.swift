//
//  BaseDismissViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/7/13.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController{
    
    var touchBeganCompletion: ((_ touchedLayer: CALayer?)-> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            
            let touchedLayer = view.layer.hitTest(currentPoint)
            
            if let touchBeganCompletion = touchBeganCompletion{
                touchBeganCompletion(touchedLayer)
            }
        }
    }
}
