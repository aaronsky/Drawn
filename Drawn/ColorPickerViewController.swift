//
//  ColorPickerViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    enum ColorMode : Int {
        case Rgb = 0
        case Hsv = 1
    }
    
    @IBOutlet weak var rgbOrHsvPicker: UISegmentedControl!
    
    @IBOutlet weak var redHueLabel: UILabel!
    @IBOutlet weak var redHueSlider: UISlider!
    @IBOutlet weak var greenSaturationLabel: UILabel!
    @IBOutlet weak var greenSaturationSlider: UISlider!
    @IBOutlet weak var blueValueLabel: UILabel!
    @IBOutlet weak var blueValueSlider: UISlider!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    
    lazy var selectedColor : UIColor = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableAlphaControls:", name: "enableAlphaControls", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableAlphaControls:", name: "disableAlphaControls", object: nil)
        resetUIForColorMode(.Rgb)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchColorState(sender: UISegmentedControl) {
        let mode = ColorMode(rawValue: sender.selectedSegmentIndex)!
        switch mode {
        case .Rgb:
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("colormode", action: "rgb", label: "rgb", value: 0).build() as [NSObject: AnyObject])
            resetUIForColorMode(.Rgb)
        case .Hsv:
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("colormode", action: "hsv", label: "hsv", value: 0).build() as [NSObject: AnyObject])
            resetUIForColorMode(.Hsv)
        }
    }
    @IBAction func colorSliderValueChanged(sender: UISlider) {
        notify()
    }
    
    func resetUIForColorMode(colorMode: ColorMode = .Rgb) {
        var rh:CGFloat = 0, gs:CGFloat = 0, bv:CGFloat = 0, alpha:CGFloat = 0
        if colorMode == .Rgb {
            selectedColor.getRed(&rh, green: &gs, blue: &bv, alpha: &alpha)
            
            redHueLabel.text = "Red"
            greenSaturationLabel.text = "Green"
            blueValueLabel.text = "Blue"
            redHueSlider.maximumValue = 255.0
            greenSaturationSlider.maximumValue = 255.0
            blueValueSlider.maximumValue = 255.0
            
            redHueSlider.value = scale(Float(rh), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 255)
            greenSaturationSlider.value = scale(Float(gs), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 255)
            blueValueSlider.value = scale(Float(bv), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 255)
            alphaSlider.value = Float(alpha)
        } else if colorMode == .Hsv {
            selectedColor.getHue(&rh, saturation: &gs, brightness: &bv, alpha: &alpha)
            
            redHueLabel.text = "Hue"
            greenSaturationLabel.text = "Saturation"
            blueValueLabel.text = "Value"
            redHueSlider.maximumValue = 360.0
            greenSaturationSlider.maximumValue = 100.0
            blueValueSlider.maximumValue = 100.0
            
            redHueSlider.value = scale(Float(rh), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 360)
            greenSaturationSlider.value = scale(Float(gs), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 100)
            blueValueSlider.value = scale(Float(bv), minStart: 0, minEnd: 1, maxStart: 0, maxEnd: 100)
            alphaSlider.value = Float(alpha)
        }
        notify()
    }
    
    func enableAlphaControls (notification: NSNotification?) {
        alphaSlider.hidden = false
        alphaSlider.enabled = true
        alphaSlider.userInteractionEnabled = true
        NSNotificationCenter.defaultCenter().postNotificationName("updateColor", object: self, userInfo: ["color":selectedColor])
    }
    
    func disableAlphaControls (notification: NSNotification?) {
        alphaSlider.userInteractionEnabled = false
        alphaSlider.enabled = false
        alphaSlider.hidden = true
        NSNotificationCenter.defaultCenter().postNotificationName("updateColor", object: self, userInfo: ["color":selectedColor])
    }
    
    func notify() {
        calculateColor()
        NSNotificationCenter.defaultCenter().postNotificationName("updateColor", object: self, userInfo: ["color":selectedColor])
    }
    
    func calculateColor () {
        let red = scale(redHueSlider.value, minStart: redHueSlider.minimumValue, minEnd: redHueSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let green = scale(greenSaturationSlider.value, minStart: greenSaturationSlider.minimumValue, minEnd: greenSaturationSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let blue = scale(blueValueSlider.value, minStart: blueValueSlider.minimumValue, minEnd: blueValueSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let mode = ColorMode(rawValue: rgbOrHsvPicker.selectedSegmentIndex)!
        switch mode {
        case .Rgb:
            selectedColor = UIColor(red: CGFloat(red) , green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alphaSlider.value))
        case .Hsv:
            selectedColor = UIColor(hue: CGFloat(red), saturation: CGFloat(green), brightness: CGFloat(blue), alpha: CGFloat(alphaSlider.value))
        }
    }
    
    func scale(x:Float, minStart:Float, minEnd:Float, maxStart:Float, maxEnd:Float) -> Float {
        return ((x - minStart) / (minEnd - minStart)) * (maxEnd - maxStart) + maxStart
    }
    
}
