//
//  SwiftHSVColorPicker.swift
//  SwiftHSVColorPicker
//
//  Created by johankasperi on 2015-08-20.
//

import UIKit

open class SwiftHSVColorPicker: UIView, ColorWheelDelegate, BrightnessViewDelegate {
    
    var colorWheel: ColorWheel!
    var brightnessView: BrightnessView!
    var selectedColorView: SelectedColorView!
    
    var delegate : ColorPickerDelegate!
    var isSelectedColorViewHidden = true

    open var color: UIColor!
    var hue: CGFloat = 1.0
    var saturation: CGFloat = 1.0
    var brightness: CGFloat = 1.0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.backgroundColor = UIColor.blue
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open func setViewColor(_ color: UIColor) {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if (!ok) {
            print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
        }
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.color = color
        setup()
    }
    
    func setup() {
        // Remove all subviews
        let views = self.subviews
        for view in views {
            view.removeFromSuperview()
        }
        
        let selectedColorViewHeight: CGFloat = 44.0
        let brightnessViewHeight: CGFloat = 26.0
        
        // let color wheel get the maximum size that is not overflow from the frame for both width and height
        let colorWheelSize = min(self.bounds.width, self.bounds.height - selectedColorViewHeight - brightnessViewHeight)
        
        // let the all the subviews stay in the middle of universe horizontally
        let centeredX = (self.bounds.width - colorWheelSize) / 2.0
        let rect = CGRect(x: 40, y:0, width: (self.bounds.width - 40*2), height: selectedColorViewHeight)
//        CGRect(x: centeredX, y:0, width: colorWheelSize, height: selectedColorViewHeight)
        // Init SelectedColorView subview
        selectedColorView = SelectedColorView(frame: rect, color: self.color)
        // Add selectedColorView as a subview of this view
        
        if !isSelectedColorViewHidden{
            self.addSubview(selectedColorView) //上面選中的顏色
        }
        
        // Init new ColorWheel subview
        colorWheel = ColorWheel(frame: CGRect(x: centeredX, y: selectedColorView.frame.maxY, width: colorWheelSize, height: colorWheelSize), color: self.color)
        colorWheel.delegate = self
        // Add colorWheel as a subview of this view
        self.addSubview(colorWheel) //顏色圈圈
        
        // Init new BrightnessView subview
        brightnessView = BrightnessView(frame: CGRect(x: centeredX, y: colorWheel.frame.maxY, width: colorWheelSize, height: brightnessViewHeight), color: self.color)
        brightnessView.delegate = self
        // Add brightnessView as a subview of this view
        self.addSubview(brightnessView) //下面亮度表
    }
    
    func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        brightnessView.setViewColor(self.color)
        selectedColorView.setViewColor(self.color)
        //把改變的顏色傳出
        delegate.current(color: self.color)
    }
    
    func brightnessSelected(_ brightness: CGFloat) {
        self.brightness = brightness
        self.color = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
        colorWheel.setViewBrightness(brightness)
        selectedColorView.setViewColor(self.color)
        //把改變的顏色傳出
        delegate.current(color: self.color)
    }
}
