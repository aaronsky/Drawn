//
//  ColorViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import Foundation
import UIKit
import iAd

class OptionsViewController: UIViewController, ADBannerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var adBannerView: ADBannerView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var opacityLayerView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var lineWidthDescriptionLabel: UILabel!
    @IBOutlet weak var lineWidthSlider: UISlider!
    
    //MARK: Members
    var isBannerVisible : Bool = false
    lazy var options : DrawingOptions = DrawingOptions()
    var selectedImage : UIImage?
    
    //MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColor:", name: "updateColor", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showImagePicker:", name: "loadBackgroundImage", object: nil)
        
        setColor(options.color)
        setLineWidth(options.lineWidth)
        lineWidthSlider.value = Float(floor(options.lineWidth))
        
        adBannerView.delegate = self
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EmbeddedColorPickerSegue" {
            //butts
            let vc = segue.destinationViewController as! ColorPickerViewController
            vc.selectedColor = options.color
        }
    }
    
    //MARK: Setters
    func setColor (color: UIColor) {
        colorView.backgroundColor = color
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        opacityLayerView.alpha = 1.0 - alpha
        colorLabel.text = String(format: "#%02X%02X%02X%02X",
            Int(red * 255.0),
            Int(green * 255.0),
            Int(blue * 255.0),
            Int(alpha * 255.0))
        if DrawingOptions.didSetBackground {
            DrawingOptions.backgroundColor = color
        } else {
            options.color = color
        }
    }
    
    func setLineWidth (width: CGFloat) {
        options.lineWidth = width
        lineWidthDescriptionLabel.text = "Line Width: \(options.lineWidth)"
    }
    
    @IBAction func lineWidthSliderValueChanged(sender: UISlider) {
        setLineWidth(CGFloat(floor(sender.value)))
    }
    
    //MARK: Notifications
    func updateColor (notification: NSNotification?) {
        if let color = notification?.userInfo?["color"] as? UIColor {
            setColor(color)
        }
    }
    
    func showImagePicker (notification: NSNotification?) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let pickerVC = UIImagePickerController()
            pickerVC.sourceType = .PhotoLibrary
            pickerVC.delegate = self
            presentViewController(pickerVC, animated: true, completion: nil)
        }
    }
    
    //MARK: ADBannerViewDelegate methods
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if isBannerVisible {
            if adBannerView.superview == nil {
                self.view.addSubview(adBannerView)
            }
            UIView.beginAnimations("animateAdBannerOn", context: nil)
            adBannerView.frame = CGRectOffset(adBannerView.frame, 0, -adBannerView.frame.height)
            UIView.commitAnimations()
            isBannerVisible = true
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("failed to receive ad")
        if isBannerVisible {
            UIView.beginAnimations("animateAdBannerOff", context: nil)
            adBannerView.frame = CGRectOffset(adBannerView.frame, 0, adBannerView.frame.height)
            UIView.commitAnimations()
            isBannerVisible = false
        }
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectedImage = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("selectedImageFromPicker", object: nil, userInfo: ["image": image])
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
