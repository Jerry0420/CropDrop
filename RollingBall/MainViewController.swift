//
//  ViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/23.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Property
    
    var tapGesture : UITapGestureRecognizer?
    var isPause = false
    var imagePicker = UIImagePickerController()
    var takedPicture : UIImage?
    var takedPictureSize : CGSize?
    var selectedColor: UIColor = UIColor.white
    var currentSize : Double = 0
    var sliderValue = 0.5
    var currentMode = 0
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    
    @IBOutlet weak var gameView: DropItView! {
        didSet {
            if currentMode == 0{
                gameView.realGravity = true
            }else{
                gameView.realGravity = false
                gameView.animating = false
            }
        }
    }
    
    // MARK: - function
    
    @objc fileprivate func setAnimation(){
        
        if currentMode == 0{
            gameView.animating = isPause
            isPause = !isPause
            
            isPause ? (statusButton.image = #imageLiteral(resourceName: "pause-Small")) : (statusButton.image = #imageLiteral(resourceName: "play-Small"))

        }
        else{
            gameView.realGravity = false
            gameView.animating = false
        }
    }
    
    fileprivate func addImage(){
        if currentMode == 0{
            gameView.realGravity = true
            gameView.animating = true
            isPause ? (statusButton.image = #imageLiteral(resourceName: "pause-Small")) : (statusButton.image = #imageLiteral(resourceName: "play-Small"))
        }else{
            gameView.realGravity = false
            gameView.animating = false
        }
        let imageWidth = Double((takedPicture?.size.width)!)
        let imageHeight = Double((takedPicture?.size.height)!)
        let screenWidth = Double(UIScreen.main.bounds.size.width)
        let screenHeight = Double(UIScreen.main.bounds.size.height - 108)
        let maxImageSize = max(imageHeight/screenHeight, imageWidth/screenWidth) //數字小
        let minImageSize = max(imageWidth/70, imageHeight/70) //數字大 70 70為設定的最圖片長寬
        
        currentSize = (minImageSize - maxImageSize)*(1 - sliderValue) + maxImageSize
        takedPictureSize = CGSize(width: imageWidth / currentSize, height: imageHeight / currentSize)
        
        gameView.addDrop(with: takedPicture!, and: takedPictureSize!, of: (currentMode == 1))
        
        takedPicture = nil
        
    }
    
    fileprivate func clearAllDrop(){
        
        gameView.clearAll()
    }
    
}

extension MainViewController : ErrorPresentDelegate{}

// MARK: - IBAction

extension MainViewController{ //IBAction
    @IBAction func share(_ sender: UIBarButtonItem) {
        showOKAlert(title: "已儲存至相簿", message: "", actionATitle: "ok") {
            UIImageWriteToSavedPhotosAlbum(self.gameView.screenshot(), nil, nil , nil)
        }
    }
    
    @IBAction func clearScreen(_ sender: UIBarButtonItem) {
        showAlert(title: "警告", message: "即將清除畫面", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: {
            self.clearAllDrop()
        }, actionBTitle: "否", actionBStyle: .default, actionBHandler: {
            
        }, completionHandler: nil)
    }
    @IBAction func chooseBackgroundColor(_ sender: UIBarButtonItem) {
        
        if !isPause {
            if currentMode == 0{
                statusButton.image = #imageLiteral(resourceName: "pause-Small")
            }
            gameView.animating = isPause
        }
        
        goToColorPickerVC()
    }
    
    @IBAction func openCamera(_ sender: UIBarButtonItem) {
        
        goToCustomCameraVC()
    }
    
    @IBAction func chooseMode(_ sender: UIBarButtonItem) {
        
        goToSettingModeVC()
    }
    
    @IBAction func showTutorials(_ sender: UIBarButtonItem) {
        showAlert(title: "教學", message: "1. 點擊下方的齒輪圖案，可以選擇“重力”模式或“編輯”模式。 \n 2. 選擇模式後，點選下方的相機圖案，新增照片。 \n 3. 編輯過程中，可隨時點選右上角的圖案儲存至相簿，或點選右下角的垃圾桶圖案清除畫面。 \n 4. 重力模式下晃晃手機 ; 編輯模式下用手指拖動或旋轉圖案。", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: nil, actionBTitle: nil, actionBStyle: nil, actionBHandler: nil, completionHandler: nil)
        
    }
}

// MARK: - life cycle

extension MainViewController{ //life cycle
    
    override func viewDidLoad() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(setAnimation))
        gameView.addGestureRecognizer(tapGesture!)
        statusButton.tintColor = UIColor.black
        navigationItem.title = "CropDrop"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
    }
}

// MARK: - 畫面轉換

extension MainViewController{ //畫面轉換
    @IBAction func backToMainPage(_ segue:UIStoryboardSegue){
        //unwind segue
        if segue.identifier == "backToMainPage"{
            
            if let imageEditingVC = segue.source as? ImageEditingViewController{
                
                if imageEditingVC.isCropable{
                    imageEditingVC.cropView.getCropImage()
                    imageEditingVC.delegate.afterEditing(of: imageEditingVC.cropView.croppedImage, and: imageEditingVC.sliderValue)
                }else{
                    let image = imageEditingVC.drawView.preRenderImage!
                    imageEditingVC.delegate.afterEditing(of: image, and: imageEditingVC.sliderValue)
                }
            }
        }
    }
    
    func goToColorPickerVC(){
        presentAnotherViewController(of: ViewControllerID.colorPickerVC) { (vc) in
            if let colorPickerVC = vc as? ColorPickerViewController{
                colorPickerVC.modalPresentationStyle = .overCurrentContext
                colorPickerVC.delegate = self
                colorPickerVC.selectedColor = self.gameView.backgroundColor!
            }
        }
    }
    
    func goToCustomCameraVC(){
        presentAnotherViewController(of: ViewControllerID.customCameraVC) { (vc) in
            if let customCameraVC = vc as? CustomCameraViewController{
                customCameraVC.isCropable = self.currentMode
                customCameraVC.delegate = self
            }
        }
    }
    
    func goToSettingModeVC(){
        presentAnotherViewController(of: ViewControllerID.settingModeVC) { (vc) in
            if let settingModeVC = vc as? SettingModeViewController{
                settingModeVC.modalPresentationStyle = .overCurrentContext
                settingModeVC.delegate = self
                settingModeVC.previousIndex = self.currentMode
            }
        }
    }
    
}

// MARK: - Delegate Implement

extension MainViewController: ColorPickerDelegate{
    func current(color: UIColor) {
        gameView.backgroundColor = color
    }
}

extension MainViewController: ImageEditingDelegete{
    
    func afterEditing(of image: UIImage, and sizeValue: Double) {
        takedPicture = image
        sliderValue = sizeValue
        addImage()
    }
}

extension MainViewController: SegmentDelegate{
    
    func current(index: Int) {
        currentMode = index
        if index == 1 {
            statusButton.image = #imageLiteral(resourceName: "noFlashLight-Small")
        }else{
            statusButton.image = #imageLiteral(resourceName: "pause-Small")
        }
        self.clearAllDrop()
        
    }
}

extension MainViewController: PresentAnotherVCDelegate{}
