//
//  UIKit Extensions.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/26.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

extension UIColor{
    static func themeColor() -> UIColor{
        let color = UIColor(red: 0.0/255.0, green: 93.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return color
    }
}

extension CGFloat {
    static func random(_ max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

extension CGRect {
    var mid: CGPoint { return CGPoint(x: midX, y: midY) }
    var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
    var lowerLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
    var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
    var lowerRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
    
    init(center: CGPoint, size: CGSize) {
        let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        self.init(origin: upperLeft, size: size)
    }
}

extension UIView {
    func hitTest(_ p: CGPoint) -> UIView? {
        return hitTest(p, with: nil)
    }
    
    func screenshot() -> UIImage {
        
        let imageSize = bounds.size as CGSize
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        for obj : AnyObject in UIApplication.shared.windows {
            if let window = obj as? UIWindow {
                if window.responds(to: #selector(getter: UIWindow.screen)) || window.screen == UIScreen.main {
                    // so we must first apply the layer's geometry to the graphics context
                    context!.saveGState();
                    // Center the context around the window's anchor point
                    context!.translateBy(x: window.center.x, y: window.center
                        .y);
                    // Apply the window's transform about the anchor point
                    context!.concatenate(window.transform);
                    // Offset by the portion of the bounds left of and above the anchor point
                    context!.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x,
                                         y: -window.bounds.size.height * window.layer.anchorPoint.y);
                    
                    // Render the layer hierarchy to the current context
                    layer.render(in: context!)
                    
                    // Restore the context
                    context!.restoreGState();
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
}

extension UIImage {
    
    func fixedOrientation(when cameraIsFront : Bool = false) -> UIImage
    {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            
            if cameraIsFront{
                //前
                let flippedImage = UIImage(cgImage: cgImage!, scale: scale, orientation: .leftMirrored)
                return flippedImage
            }else{
                //後
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: CGFloat.pi / -2.0)
            }
            break
        case .up, .upMirrored:
            break
        }
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

//需要用到的VC，再使用此delegate即可
protocol ErrorPresentDelegate {
    func showAlert(title: String, message: String, style: UIAlertControllerStyle, actionATitle: String, actionAStyle: UIAlertActionStyle,actionAHandler: (()->())?, actionBTitle: String?, actionBStyle: UIAlertActionStyle?,actionBHandler: (()->())?, completionHandler: (()->())?)
    func showOKAlert(title: String, message: String, actionATitle: String,actionAHandler: (()->())?)
    
    func showAlertWithTextField(title: String, message: String, actionATitle: String,actionAHandler: ((_ email: String)->())?, actionBTitle: String, placeHolder: String)
}

protocol PresentAnotherVCDelegate {
    func presentAnotherViewController(of identifier: String, with completion: ((_ vc: UIViewController)->())?)
}

extension PresentAnotherVCDelegate where Self: UIViewController{
    func presentAnotherViewController(of identifier: String, with completion: ((_ vc: UIViewController)->())?){
        let presentedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let completion = completion{
            completion(presentedViewController)
        }
        
        present(presentedViewController, animated: true, completion: nil)
    }
}

extension ErrorPresentDelegate where Self: UIViewController{
    
    func showAlert(title: String, message: String, style: UIAlertControllerStyle, actionATitle: String, actionAStyle: UIAlertActionStyle,actionAHandler: (()->())?, actionBTitle: String?, actionBStyle: UIAlertActionStyle?,actionBHandler: (()->())?, completionHandler: (()->())?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let actionA = UIAlertAction(title: actionATitle, style: actionAStyle, handler: {
            action in
            
            if let actionAHandler = actionAHandler{
                actionAHandler()
            }
        })
        alertController.addAction(actionA)
        
        if let actionBTitle = actionBTitle,let actionBStyle = actionBStyle, let actionBHandler = actionBHandler{
            
            let actionB = UIAlertAction(title: actionBTitle, style: actionBStyle, handler: {
                action in
                
                actionBHandler()
                
            })
            alertController.addAction(actionB)
        }
        
        if let completionHandler = completionHandler{completionHandler()}
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showOKAlert(title: String, message: String, actionATitle: String,actionAHandler: (()->())?){
        
        showAlert(title: title, message: message, style: .alert, actionATitle: actionATitle, actionAStyle: .default, actionAHandler: actionAHandler, actionBTitle: nil, actionBStyle: nil, actionBHandler: nil, completionHandler: nil)
    }
    
    func showAlertWithTextField(title: String, message: String, actionATitle: String,actionAHandler: ((_ email: String)->())?, actionBTitle: String, placeHolder: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var inputText = ""
        var alertTextField = UITextField()
        
        let actionA = UIAlertAction(title: actionATitle, style: .default, handler: {
            action in
            
            inputText = alertTextField.text!
            
            if let actionAHandler = actionAHandler{
                actionAHandler(inputText)
            }
        })
        
        let actionB = UIAlertAction(title: actionBTitle, style: .default, handler: nil)
        
        alertController.addTextField()
        alertController.addAction(actionA)
        alertController.addAction(actionB)
        
        present(alertController, animated: true, completion: nil)
        
        if let textField = alertController.textFields?.first{
            alertTextField = textField
            alertTextField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName:UIColor.gray])
            
        }
    }
}
