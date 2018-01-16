//
//  ImageEditingViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/27.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

protocol ImageEditingDelegete{
    func afterEditing(of image: UIImage, and sizeValue: Double)
}

// MARK: - Property
class ImageEditingViewController: UIViewController {
    
    var image : UIImage!
    var delegate : ImageEditingDelegete!
    
    var cropView: CropView!
    var drawView: DrawingView!
    var sizeShadowView : UIImageView!
    
    var beforeEditingImageSize : CGSize?
    
    var imageWidth : Double = 0.0
    var imageHeight : Double = 0.0
    var screenWidth : Double = 0.0
    var screenHeight : Double = 0.0
    var maxImageSize : Double = 0.0
    var minImageSize : Double = 0.0
    
    var sliderValue: Double = 1.0
    
    var isCropable = false
    
    var takedPictureSize : CGSize?
    var currentSize : Double = 0
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    fileprivate func changeFrame(of view: UIView){
        
        currentSize = (minImageSize - maxImageSize)*(1 - sliderValue) + maxImageSize
        takedPictureSize = CGSize(width: imageWidth / currentSize, height: imageHeight / currentSize)
        view.frame.size = takedPictureSize!
        view.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.width / 1.09)
        isCropable ? cropView.setNeedsDisplay() : drawView.setNeedsDisplay()
        
        sizeShadowView.setNeedsDisplay()
    }
    
}
// MARK: - 畫面跳轉
extension ImageEditingViewController{
    func goToColorPickerVC(){
        presentAnotherViewController(of: ViewControllerID.colorPickerVC, with: { (vc) in
            if let colorPickerVC = vc as? ColorPickerViewController{
                colorPickerVC.modalPresentationStyle = .overCurrentContext
                colorPickerVC.delegate = self
                colorPickerVC.isSelectedColorViewHidden = false
                self.isCropable ? (colorPickerVC.selectedColor = self.cropView.drawColor):(colorPickerVC.selectedColor = self.drawView.drawColor)
            }
        })
    }
    
    func goToSettingSizeVC(){
        presentAnotherViewController(of: ViewControllerID.settingSizeVC, with: { (vc) in
            if let settingSizeVC = vc as? SettingSizeViewController{
                settingSizeVC.modalPresentationStyle = .overCurrentContext
                settingSizeVC.delegate = self
                settingSizeVC.currentValue = self.sliderValue
            }
        })
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - IBAction function
extension ImageEditingViewController{ //按鈕功能
    
    @IBAction func undo(_ sender: UIBarButtonItem) {
        //清掉線
        if isCropable{
            cropView.cancelCrop()
        }else{
            
            drawView.layer.contents = image.cgImage
            drawView.preRenderImage = image
            
            drawView.layoutSubviews()
        }
    }
    
    @IBAction func choosePanColor(_ sender: UIBarButtonItem) {
        
        
        goToColorPickerVC()
    }
    
    @IBAction func settingSize(_ sender: UIBarButtonItem) {
        
        goToSettingSizeVC()
    }
    
    @IBAction func showTutorials(_ sender: UIBarButtonItem) {
        showAlert(title: "教學", message: "1. 重力模式下，可點選下方畫筆圖案，選擇畫筆顏色，於圖上作畫。 \n 2. 編輯模式下，可於圖上圈選出任意圖形的區域。 \n 3. 以上兩種模式下，編輯完成後，按下右上角的Done，即可回到主頁。", style: .alert, actionATitle: "是", actionAStyle: .default, actionAHandler: nil, actionBTitle: nil, actionBStyle: nil, actionBHandler: nil, completionHandler: nil)
        
    }
    
}

// MARK: - Delegate Implement

extension ImageEditingViewController: ColorPickerDelegate{
    func current(color: UIColor) {
        isCropable ? (cropView.drawColor = color):(drawView.drawColor = color)
    }
}

extension ImageEditingViewController: SliderDelegate{
    func current(slider: UISlider) {
        sliderValue = Double(slider.value)
        isCropable ? cropView.removeFromSuperview() : drawView.removeFromSuperview()
        changeFrame(of: sizeShadowView)
        view.addSubview(sizeShadowView)
        view.layoutSubviews()
    }
    
    func willDismissSlider() {
        sizeShadowView.removeFromSuperview()
        let rect = sizeShadowView.frame
        isCropable ? (cropView.frame = rect) : (drawView.frame = rect)
        isCropable ? view.addSubview(cropView) : view.addSubview(drawView)
        view.layoutSubviews()
    }
}

extension ImageEditingViewController: PresentAnotherVCDelegate{}
extension ImageEditingViewController: ErrorPresentDelegate{}

// MARK: - Lide cycle

extension ImageEditingViewController{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageWidth = Double((image?.size.width)!)
        imageHeight = Double((image?.size.height)!)
        screenWidth = Double(UIScreen.main.bounds.size.width)
        screenHeight = Double(UIScreen.main.bounds.size.height - 108)
        maxImageSize = max(imageHeight/screenHeight, imageWidth/screenWidth)
        minImageSize = max(imageWidth/70, imageHeight/70) //數字 70 70為設定的最大圖片長寬
        
        //        beforeEditingImageSize = CGSize(width: imageWidth / maxImageSize, height: imageHeight / maxImageSize)
        
        
        if isCropable{
            navItem.title = "編輯模式 - Crop"
            cropView = CropView(frame: CGRect.zero)
            cropView.isUserInteractionEnabled = true
            cropView.image = image
            cropView.contentMode = .scaleAspectFit
            
            view.addSubview(cropView)
        }else{
            navItem.title = "重力模式 - Drop"
            drawView = DrawingView(frame: CGRect.zero)
            drawView.layer.contents = image.cgImage
            drawView.layer.contentsGravity = "resizeAspect"
            drawView.preRenderImage = image
            drawView.isUserInteractionEnabled = true
            
            view.addSubview(drawView)
        }
        
        sizeShadowView = UIImageView(frame: CGRect.zero)
        sizeShadowView.image = image
        sizeShadowView.contentMode = .scaleAspectFit
    }
    
    override func viewDidLayoutSubviews() {
        isCropable ? (changeFrame(of: cropView)) : (changeFrame(of: drawView))
    }
}
