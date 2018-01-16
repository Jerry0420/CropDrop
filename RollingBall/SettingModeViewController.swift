//
//  SettingModeViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/7/8.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

protocol SegmentDelegate{
    func current(index: Int)
}

// MARK: - property
class SettingModeViewController: BaseViewController {

    var delegate : SegmentDelegate!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var settingModeSegment: UISegmentedControl!
    var previousIndex = 0
    
    @objc fileprivate func changeSegmentValue(){
        
        showAlert(title: "警告", message: "切換模式將清除畫面，是否確定？", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: {
            self.delegate.current(index: self.settingModeSegment.selectedSegmentIndex)
        }, actionBTitle: "否", actionBStyle: .default, actionBHandler: {
            self.settingModeSegment.selectedSegmentIndex = self.previousIndex
        }, completionHandler: nil)
    }
}

// MARK: - delegate implement
extension SettingModeViewController : ErrorPresentDelegate{}

// MARK: - 畫面轉換
extension SettingModeViewController{ //畫面轉換
    
    func dismissWithTouchBegan(){
        
        touchBeganCompletion = {
            
            if let touchedLayer = $0{
                if touchedLayer != self.backgroundView.layer && touchedLayer != self.settingModeSegment.layer{
                    
                    self.dismissSegmentControl()
                }
            }
        }
    }
    
    func dismissSegmentControl(){
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - life cycle

extension SettingModeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        settingModeSegment.addTarget(self, action: #selector(changeSegmentValue), for: .valueChanged)
        settingModeSegment.selectedSegmentIndex = previousIndex
        
        dismissWithTouchBegan()
    }
}
