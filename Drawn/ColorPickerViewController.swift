//
//  ColorPickerViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit
import iAd

class ColorPickerViewController: UIViewController, ADBannerViewDelegate {
    enum ColorMode : Int {
        case Rgb = 0
        case Hsv = 1
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var rgbOrHsvPicker: UISegmentedControl!
    @IBOutlet weak var redHueLabel: UILabel!
    @IBOutlet weak var redHueSlider: UISlider!
    @IBOutlet weak var greenSaturationLabel: UILabel!
    @IBOutlet weak var greenSaturationSlider: UISlider!
    @IBOutlet weak var blueValueLabel: UILabel!
    @IBOutlet weak var blueValueSlider: UISlider!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var opacityLayerView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var oldColorView: UIView!
    @IBOutlet weak var oldOpacityLayerView: UIImageView!
    @IBOutlet weak var adBannerView: ADBannerView!
    
    //MARK: Members
    var isBannerVisible : Bool = false
    lazy var selectedColor : UIColor = UIColor()
    private var isAlphaVisible : Bool = true
    
    //MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        isAlphaVisible = DrawingOptions.selectedLayer != LayerEnum.Background
        
        alphaLabel.userInteractionEnabled = isAlphaVisible
        alphaLabel.hidden = !isAlphaVisible
        alphaSlider.userInteractionEnabled = isAlphaVisible
        alphaSlider.hidden = !isAlphaVisible
        opacityLayerView.hidden = !isAlphaVisible
        
        updateColor(selectedColor, updateOld: true)
        resetUIForColorMode(.Rgb)
        
        adBannerView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        updateColor()
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
        updateColor()
    }
    
    func calculateColor () -> UIColor {
        let red = scale(redHueSlider.value, minStart: redHueSlider.minimumValue, minEnd: redHueSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let green = scale(greenSaturationSlider.value, minStart: greenSaturationSlider.minimumValue, minEnd: greenSaturationSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let blue = scale(blueValueSlider.value, minStart: blueValueSlider.minimumValue, minEnd: blueValueSlider.maximumValue, maxStart: 0.0, maxEnd: 1.0)
        let mode = ColorMode(rawValue: rgbOrHsvPicker.selectedSegmentIndex)!
        switch mode {
        case .Rgb:
            return UIColor(red: CGFloat(red) , green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alphaSlider.value))
        case .Hsv:
            return UIColor(hue: CGFloat(red), saturation: CGFloat(green), brightness: CGFloat(blue), alpha: CGFloat(alphaSlider.value))
        }
    }
    
    func updateColor () {
        let color = calculateColor()
        updateColor(color)
    }
    
    func updateColor (color: UIColor, updateOld flag: Bool = false) {
        colorView.backgroundColor = color
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if flag {
            oldColorView.backgroundColor = color
        }
        if isAlphaVisible {
            if flag {
                oldOpacityLayerView.alpha = 1.0 - alpha
            }
            opacityLayerView.alpha = 1.0 - alpha
            colorLabel.text = String(format: "#%02X%02X%02X%02X",
                Int(red * 255.0),
                Int(green * 255.0),
                Int(blue * 255.0),
                Int(alpha * 255.0))
        } else {
            colorLabel.text = String(format: "#%02X%02X%02X",
                Int(red * 255.0),
                Int(green * 255.0),
                Int(blue * 255.0))
            
        }
        if DrawingOptions.didSetBackground {
            DrawingOptions.backgroundColor = color
        } else {
            selectedColor = color
        }
    }
        
    //MARK: ADBannerViewDelegate methods
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if isBannerVisible {
            if adBannerView.superview == nil {
                self.view.addSubview(adBannerView)
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.adBannerView.frame = CGRectOffset(self.adBannerView.frame, 0, -self.adBannerView.frame.height)
                }, completion: { (success) -> Void in
                    if success {
                        self.isBannerVisible = true
                    }
            })
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("failed to receive ad")
        if isBannerVisible {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.adBannerView.frame = CGRectOffset(self.adBannerView.frame, 0, self.adBannerView.frame.height)
                }, completion: { (success) -> Void in
                    if success {
                        self.isBannerVisible = false
                    }
            })
        }
    }
    
}
