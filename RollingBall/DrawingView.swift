//
//  DrawingView.swift
//  RollingBall
//
//  Created by JerryWang on 2017/6/27.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit

class CropView: UIImageView {
    
    var drawColor = UIColor.white
    var lineWidth: CGFloat = 5
    
    var bezierPath: UIBezierPath!
    var shapeLayer = CAShapeLayer()
    var croppedImage = UIImage()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBezierPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initBezierPath()
    }
    
    func initBezierPath() {
        bezierPath = UIBezierPath()
    }
    
    // MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?{
            let touchPoint = touch.location(in: self)
            print("touch begin to : \(touchPoint)")
            bezierPath.move(to: touchPoint)
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?{
            let touchPoint = touch.location(in: self)
            print("touch moved to : \(touchPoint)")
            bezierPath.addLine(to: touchPoint)
            addNewPathToImage()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?{
            let touchPoint = touch.location(in: self)
            print("touch ended at : \(touchPoint)")
            bezierPath.addLine(to: touchPoint)
            addNewPathToImage()
            bezierPath.close()
            setCropImage()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let touch = touches?.first as UITouch?{
            let touchPoint = touch.location(in: self)
            print("touch canceled at : \(touchPoint)")
            bezierPath.close()
            setCropImage()
        }
    }
    
    func addNewPathToImage(){
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = drawColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        layer.addSublayer(shapeLayer)
    }
    
    func setCropImage(){
        shapeLayer.fillColor = UIColor.black.cgColor
        layer.mask = shapeLayer
        isUserInteractionEnabled = false
    }
    
    func getCropImage(){
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.croppedImage = newImage!
    }
    
    func cancelCrop(){
        shapeLayer.removeFromSuperlayer()
        bezierPath = UIBezierPath()
        shapeLayer = CAShapeLayer()
        isUserInteractionEnabled = true
    }
    
}

class DrawingView: UIView {
    
    var drawColor = UIColor.white
    var lineWidth: CGFloat = 5
    
    private var lastPoint: CGPoint!
    private var bezierPath: UIBezierPath!
    private var pointCounter: Int = 0
    private let pointLimit: Int = 128
    var preRenderImage: UIImage!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBezierPath()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initBezierPath()
    }
    
    func initBezierPath() {
        bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = CGLineCap.round
        bezierPath.lineJoinStyle = CGLineJoin.round
        
    }
    
    override func layoutSubviews() {
        
        //加上以下兩個end函數，畫圖時才不會lag => 因為先 bezierPath.removeAllPoints()
        touchesEnded([UITouch()], with: nil)
    }
    
    // MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        lastPoint = touch!.location(in: self)
        pointCounter = 0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        let newPoint = touch!.location(in: self)
        
        bezierPath.move(to: lastPoint)
        bezierPath.addLine(to: newPoint)
        lastPoint = newPoint
        
        pointCounter += 1
        
        if pointCounter == pointLimit {
            pointCounter = 0
            renderToImage()
            setNeedsDisplay()
            bezierPath.removeAllPoints()
        }
        else {
            setNeedsDisplay()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pointCounter = 0
        renderToImage()
        setNeedsDisplay()
        bezierPath.removeAllPoints()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        touchesEnded(touches!, with: event)
    }
    
    
    // MARK: - Pre render
    
    func renderToImage() {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
        
        preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    // MARK: - Render
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
        
    }
    
    // MARK: - Clearing
    
    func clear() {
        preRenderImage = nil
        bezierPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    // MARK: - Other
    
    func hasLines() -> Bool {
        return preRenderImage != nil || !bezierPath.isEmpty
    }
    
}
