//
//  ColorPickerViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/26.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate{
    func current(color: UIColor)
}


// MARK: - property

class ColorPickerViewController: BaseViewController {
    
    var delegate : ColorPickerDelegate!
    
    var selectedColor: UIColor = UIColor.white
    
    var isSelectedColorViewHidden = true
    
    @IBOutlet weak var colorPicker: SwiftHSVColorPicker!{
        didSet{
            colorPicker.isSelectedColorViewHidden = isSelectedColorViewHidden
        }
    }
    
    @IBOutlet weak var rightPadding: UIView!
    
    @IBOutlet weak var leftPadding: UIView!
    
}

// MARK: - 畫面轉換

extension ColorPickerViewController{ //畫面轉換
    
    func dismissWithTouchBegan(){
        
        touchBeganCompletion = {
            
            if let touchedLayer = $0{
                if touchedLayer != self.colorPicker.layer && touchedLayer != self.leftPadding.layer && touchedLayer != self.rightPadding.layer{
                    
                    self.dismissColorPicker()
                }
            }
        }
    }
    
    func dismissColorPicker(){
        selectedColor = colorPicker.color
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - life cycle

extension ColorPickerViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.setViewColor(selectedColor)
        colorPicker.delegate = delegate
        
        dismissWithTouchBegan()
    }
}
