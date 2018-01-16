//
//  DropItView.swift
//  DropIt
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate
{
    var viewTag = 0
    var images = [UIView]()
    
    // MARK: - Public API
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(dropBehavior)
                updateRealGravity()
                
            } else {
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    func addDrop(with image: UIImage, and size: CGSize, of gesture: Bool)
    {
        var frame = CGRect(origin: CGPoint.zero, size: size)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = Drop(frame: frame)
        drop.backgroundColor = UIColor.clear
        drop.layer.contents = image.cgImage
        drop.layer.contentsGravity = "resizeAspect"
        drop.clipsToBounds = true
        
        //gesture為true的時候代表要加上手勢
        drop.isPanable = gesture
        drop.setpanGesture()
        
        images.append(drop)
        
        addSubview(drop)
        dropBehavior.addItem(drop)
        
    }
    
    func clearAll(){
        for image in images{
            self.dropBehavior.removeItem(image)
            image.removeFromSuperview()
        }
    }
    
    // MARK: - Private Implementation
    
    fileprivate let dropsPerRow = 1
    
    fileprivate var dropSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    fileprivate let dropBehavior = FallingObjectBehavior()
    
    fileprivate lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    fileprivate struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    // MARK: - Collision Boundary
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        moveBarrier()
    }
    
    func moveBarrier(){
        
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize)) //把path改成貝氏曲線
        dropBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        bezierPaths[PathNames.MiddleBarrier] = path
        
    }
    
    // MARK: - Core Motion
    
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                
                motionManager.startAccelerometerUpdates(to: OperationQueue.main)
                { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            //改變重力
                            
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0;
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                            
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
}

// MARK: - Drop View with gesture

class Drop: UIView{
    
    var isPanable = false
    
    func setpanGesture(){
        if isPanable{
            
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            pan.delaysTouchesBegan = true
            addGestureRecognizer(pan)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(rotate:)))
            
            addGestureRecognizer(rotate)
        }
    }
    
    func handlePanGesture(pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: superview)
        
        let originalCenter = center
        center = CGPoint(x:originalCenter.x + translation.x, y:originalCenter.y + translation.y)
        pan.setTranslation(CGPoint.zero, in: superview)
    }
    
    func handleRotate(rotate : UIRotationGestureRecognizer){
        transform = transform.rotated(by: rotate.rotation)
        rotate.rotation = 0
    }
    
}
