/*
The MIT License (MIT)

Copyright (c) 2015-present Badoo Trading Limited.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import UIKit

class DrawImageView : UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupGestureRecognizers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFit
//        layer.contentsGravity = "resizeAspect"
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Drawing a path
    
    fileprivate func drawLine(_ a: CGPoint, b: CGPoint, buffer: UIImage?) -> UIImage {
        let size = self.bounds.size
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context?.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        // Draw the line
        self.drawColor.setStroke()
        context?.setLineWidth(self.drawWidth)
        context?.setLineCap(CGLineCap.round)
        
        context?.move(to: CGPoint(x: a.x, y: a.y))
        context?.addLine(to: CGPoint(x: b.x, y: b.y))
        context?.strokePath()
        
        // Grab the updated buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: Gestures
    
    fileprivate func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.handlePan(_:)))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began:
            self.startAtPoint(point)
        case .changed:
            self.continueAtPoint(point)
        case .ended:
            self.endAtPoint(point)
        case .failed:
            self.endAtPoint(point)
        default:
            assert(false, "State not handled")
        }
    }
    
    // MARK: Tracing a line
    
    fileprivate func startAtPoint(_ point: CGPoint) {
        self.lastPoint = point
        
    }
    
    fileprivate func continueAtPoint(_ point: CGPoint) {
        autoreleasepool {
            // 2. Draw the current stroke in an accumulated bitmap
            self.buffer = self.drawLine(self.lastPoint, b: point, buffer: self.buffer)
            
            // 3. Replace the layer contents with the updated image
            image = self.buffer ?? nil
            // 4. Update last point for next stroke
            self.lastPoint = point
        }
    }
    
    fileprivate func endAtPoint(_ point: CGPoint) {
        self.lastPoint = CGPoint.zero
    }
    
    var drawColor: UIColor = UIColor.black
    var drawWidth: CGFloat = 10.0
    
    fileprivate var lastPoint: CGPoint = CGPoint.zero
    var buffer: UIImage?
}

class DrawView : UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupGestureRecognizers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.contentsGravity = "resizeAspect"
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Drawing a path
    
    fileprivate func drawLine(_ a: CGPoint, b: CGPoint, buffer: UIImage?) -> UIImage {
        let size = self.bounds.size
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context?.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        // Draw the line
        self.drawColor.setStroke()
        context?.setLineWidth(self.drawWidth)
        context?.setLineCap(CGLineCap.round)
        
        context?.move(to: CGPoint(x: a.x, y: a.y))
        context?.addLine(to: CGPoint(x: b.x, y: b.y))
        context?.strokePath()
        
        // Grab the updated buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: Gestures
    
    fileprivate func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.handlePan(_:)))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began:
            self.startAtPoint(point)
        case .changed:
            self.continueAtPoint(point)
        case .ended:
            self.endAtPoint(point)
        case .failed:
            self.endAtPoint(point)
        default:
            assert(false, "State not handled")
        }
    }
    
    // MARK: Tracing a line
    
    fileprivate func startAtPoint(_ point: CGPoint) {
        self.lastPoint = point
        
    }
    
    fileprivate func continueAtPoint(_ point: CGPoint) {
        autoreleasepool {
            // 2. Draw the current stroke in an accumulated bitmap
            self.buffer = self.drawLine(self.lastPoint, b: point, buffer: self.buffer)
            
            // 3. Replace the layer contents with the updated image
            self.layer.contents = self.buffer?.cgImage ?? nil
            // 4. Update last point for next stroke
            self.lastPoint = point
        }
    }
    
    fileprivate func endAtPoint(_ point: CGPoint) {
        self.lastPoint = CGPoint.zero
    }
    
    var drawColor: UIColor = UIColor.black
    var drawWidth: CGFloat = 10.0
    
    fileprivate var lastPoint: CGPoint = CGPoint.zero
    var buffer: UIImage?
}
