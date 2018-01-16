//
//  SettingSizeViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/26.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

protocol SliderDelegate{
    func current(slider: UISlider)
    func willDismissSlider()
}

// MARK: - Property

class SettingSizeViewController: BaseViewController {
    
    @IBOutlet weak var sizeSlider: UISlider!
    var delegate : SliderDelegate!
    
    @IBOutlet weak var backgroundView: UIView!
    var currentValue = 0.0
    
    @objc fileprivate func changeSliderValue(){
        delegate.current(slider: sizeSlider)
    }
}

// MARK: - 畫面跳轉
extension SettingSizeViewController{
    
    func dismissWithTouchBegan(){
        
        touchBeganCompletion = {
            
            if let touchedLayer = $0{
                if touchedLayer != self.backgroundView.layer && touchedLayer != self.sizeSlider.layer{
                    self.sizeSlider.value += 0.0001
                    self.changeSliderValue()
                    self.delegate.willDismissSlider()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
// MARK: - life cycle
extension SettingSizeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeSlider.value = Float(currentValue)
        sizeSlider.addTarget(self, action: #selector(changeSliderValue), for: .allEvents)
        dismissWithTouchBegan()
    }
}
