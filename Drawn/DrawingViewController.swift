//
//  ViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/7/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit
import Photos

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var drawingView: DrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.hidesBarsOnTap = true
        navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: "toggleNavBar:")
        navigationController?.setNavigationBarHidden(true, animated: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveCurrentDrawing:", name: "suspending", object: nil)
        
        let path = FilePathInDocumentsDirectory("pointsFromClose.archive")
        if let layers = NSKeyedUnarchiver.unarchiveObjectWithFile(path) {
            drawingView.layers = layers as! [Layer]
            print("Layers=\(drawingView.layers)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return (navigationController?.navigationBarHidden)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveCurrentDrawing (notification: NSNotification) {
        let path = FilePathInDocumentsDirectory("pointsFromClose.archive")
        let success = NSKeyedArchiver.archiveRootObject(drawingView.layers, toFile: path)
        print("Saved \(success) to \(path)")
    }
    
    func toggleNavBar (tap: UITapGestureRecognizer) {
        prefersStatusBarHidden()
    }
    
    func promptClear() {
        let alertVC = UIAlertController(title: "Delete Drawing", message: "Delete your beautiful drawing?", preferredStyle: .Alert)
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus != PHAuthorizationStatus.Denied {
            let saveAndDeleteAction = UIAlertAction(title: "Save and Delete", style: .Default) { (_) in
                let image = self.drawingView.createImageFromContext()
                if authStatus == PHAuthorizationStatus.Authorized {
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    self.drawingView.clear()
                } else if authStatus == PHAuthorizationStatus.NotDetermined {
                    PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                        if status == PHAuthorizationStatus.Authorized {
                            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                            self.drawingView.clear()
                        }
                    })
                }
            }
            alertVC.addAction(saveAndDeleteAction)
        }
        let deleteWithoutSavingAction = UIAlertAction(title: "Delete Without Saving", style: .Destructive) { (_) in
            self.drawingView.clear()
        }
        alertVC.addAction(deleteWithoutSavingAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true) { () in }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            promptClear()
        }
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        if (size.width > size.height)
//        {
//            // Position elements for Landscape
//            drawingView.transpose(.Landscape)
//            drawingView.setNeedsDisplay()
//        }
//        else
//        {
//            // Position elements for Portrait
//            drawingView.transpose(.Portrait)
//            drawingView.setNeedsDisplay()
//        }
//    }
    
    @IBAction func undo(sender: AnyObject) {
        self.drawingView.undoStroke()
    }
    
    @IBAction func clearDrawing(sender: AnyObject) {
        promptClear()
    }
    
    @IBAction func shareDrawing(sender: AnyObject) {
        let image = drawingView.createImageFromContext()
        let messageText = ""
        let activityVC = UIActivityViewController(activityItems: [messageText, image!], applicationActivities: nil)
        presentViewController(activityVC, animated: true) { () in }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColorWheelSegue" {
            let vc = segue.destinationViewController as! OptionsViewController
            vc.options = drawingView.options
        }
    }
    
    @IBAction func prepareForUnwind (segue: UIStoryboardSegue) {
        if let optionsVC = segue.sourceViewController as? OptionsViewController {
            drawingView.options = optionsVC.options
            drawingView.backgroundColor = DrawingOptions.backgroundColor
            DrawingOptions.didSetBackground = false
        }
    }
}

