//
//  CustomCameraViewController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/7/10.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import Photos

// MARK: - Property and Function

class CustomCameraViewController: UIViewController {
    
    @IBOutlet weak var captureButton: UIView!
    
    @IBOutlet weak var capturePreviewView: UIView!
    
    @IBOutlet weak var cameraModeButton: UIButton!
    
    @IBOutlet weak var flashLightButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let cameraController = CameraController()
    
    var isCropable = 0
    var delegate : ImageEditingDelegete!
    fileprivate var isfrontCamera = false
    
    var photoLibrary : PhotoLibrary?
    
    fileprivate func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    fileprivate func styleCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2
        
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
    fileprivate func setUpPhotoLibrary(){
        photoLibrary = PhotoLibrary()
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            if result == .authorized {
                self?.photoLibrary?.setPhoto(at: ((self?.photoLibrary?.count)! - 1)) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            //                            self?.imageView.image = image.fixedOrientation(when: (self?.isfrontCamera)!)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - delegate implement
extension CustomCameraViewController: PresentAnotherVCDelegate{}

// MARK: - IBAction function

extension CustomCameraViewController{ //按鈕功能
    
    @objc fileprivate func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            print("flash off")
            flashLightButton.setImage(#imageLiteral(resourceName: "noFlashLight-Small"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            print("flash on")
            flashLightButton.setImage(#imageLiteral(resourceName: "flashLight-Small"), for: .normal)
        }
    }
    
    @objc fileprivate func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            print("front")
            isfrontCamera = true
            cameraController.flashMode = .off
            flashLightButton.isEnabled = false
            
        case .some(.rear):
            print("rear")
            isfrontCamera = false
            flashLightButton.isEnabled = true
            flashLightButton.setImage(#imageLiteral(resourceName: "noFlashLight-Small"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @objc fileprivate func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            
            self.imageView.image = image.fixedOrientation(when: self.isfrontCamera)
            
            self.goToImageEditingVC(with: image)
        }
    }
    
}
// MARK: - 畫面跳轉
extension CustomCameraViewController{
    func goToImageEditingVC(with image: UIImage){
        self.presentAnotherViewController(of: ViewControllerID.imageEditingVC, with: { (vc) in
            if let imageEditingVC = vc as? ImageEditingViewController{
                imageEditingVC.image = image.fixedOrientation(when: self.isfrontCamera)
                
                imageEditingVC.delegate = self.delegate
                imageEditingVC.isCropable = (self.isCropable == 1)
            }
        })
    }
    
    @objc fileprivate func back(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSelectImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - Image Picker

extension CustomCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker{
            
            let imageEditingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ViewControllerID.imageEditingVC) as! ImageEditingViewController
            
            imageEditingVC.image = selectedImage
            
            imageEditingVC.delegate = self.delegate
            imageEditingVC.isCropable = (self.isCropable == 1)
            
            picker.present(imageEditingVC, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Life cycle

extension CustomCameraViewController{ //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleCaptureButton()
        configureCameraController()
        
        flashLightButton.addTarget(self, action: #selector(toggleFlash(_:)), for: .touchUpInside)
        cameraModeButton.addTarget(self, action: #selector(switchCameras(_:)), for: .touchUpInside)
        captureButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(captureImage(_:))))
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        imageView.isUserInteractionEnabled = true
        
        setUpPhotoLibrary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}
