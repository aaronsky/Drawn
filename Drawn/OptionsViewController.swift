//
//  ColorViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import Foundation
import UIKit

class OptionsViewController: UIViewController {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var lineWidthDescriptionLabel: UILabel!
    
    lazy var options : DrawingOptions = DrawingOptions()
    var didSetBackground : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColor:", name: "updateColor", object: nil)
        
        setColor(options.color)
        setLineWidth(options.lineWidth)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func setColor (color: UIColor) {
        colorView.backgroundColor = color
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        colorLabel.text = String(format: "#%02X%02X%02X%02X",
            Int(red * 255.0),
            Int(green * 255.0),
            Int(blue * 255.0),
            Int(alpha * 255.0))
        if DrawingOptions.selectedLayer == 3 {
            DrawingOptions.backgroundColor = color
            didSetBackground = true
        } else {
            options.color = color
        }
    }
    
    func setLineWidth (width: CGFloat) {
        options.lineWidth = width
        lineWidthDescriptionLabel.text = "Line Width: \(options.lineWidth)"
    }
    
    func updateColor (notification: NSNotification?) {
        if let color = notification?.userInfo?["color"] as? UIColor {
            setColor(color)
        }
    }
    
    @IBAction func lineWidthSliderValueChanged(sender: UISlider) {
        setLineWidth(CGFloat(floor(sender.value)))
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EmbeddedColorPickerSegue" {
            //butts
            let vc = segue.destinationViewController as! ColorPickerViewController
            vc.selectedColor = options.color
        }
    }

}
