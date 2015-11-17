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
    
    override func shouldAutorotate() -> Bool {
        if drawingView != nil {
            return !drawingView.hasStartedDrawing()
        }
        return true
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
    
    func promptSaveBeforeClear() {
        let alertVC = UIAlertController(title: "Delete Drawing", message: "Delete your beautiful drawing?", preferredStyle: .Alert)
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus != PHAuthorizationStatus.Denied {
            let saveAndDeleteAction = UIAlertAction(title: "Save and Delete", style: .Default) { (_) in
                GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("Delete", action: "Saved", label: "Saved before deleting", value: 0).build() as [NSObject: AnyObject])
                let image = self.drawingView.createImageFromContext()
                if authStatus == PHAuthorizationStatus.Authorized {
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    self.promptPreserveBackgroundImageForClear()
                } else if authStatus == PHAuthorizationStatus.NotDetermined {
                    PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                        if status == PHAuthorizationStatus.Authorized {
                            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                            self.promptPreserveBackgroundImageForClear()
                        }
                    })
                }
            }
            alertVC.addAction(saveAndDeleteAction)
        }
        let deleteWithoutSavingAction = UIAlertAction(title: "Delete Without Saving", style: .Destructive) { (_) in
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("Delete", action: "No Save", label: "Did not save before deleting", value: 0).build() as [NSObject: AnyObject])
            self.promptPreserveBackgroundImageForClear()
        }
        alertVC.addAction(deleteWithoutSavingAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func promptPreserveBackgroundImageForClear() {
        if self.drawingView.backgroundImage != nil {
            let alertVC = UIAlertController(title: "A background image exists", message: "You have a background image set. Do you want to get rid of it?", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "Yes, destroy it", style: .Destructive, handler: { (action) -> Void in
                self.drawingView.clear()
            }))
            alertVC.addAction(UIAlertAction(title: "No, keep it", style: .Default, handler: { (action) -> Void in
                self.drawingView.clear(clearImage: false)
            }))
            presentViewController(alertVC, animated: true, completion: nil)
        } else {
            self.drawingView.clear()
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            promptSaveBeforeClear()
        }
    }
    
    @IBAction func undo(sender: AnyObject) {
        self.drawingView.undoStroke()
    }
    
    @IBAction func clearDrawing(sender: AnyObject) {
        promptSaveBeforeClear()
    }
    
    @IBAction func shareDrawing(sender: AnyObject) {
        let image = drawingView.createImageFromContext()
        let messageText = ""
        let activityVC = UIActivityViewController(activityItems: [messageText, image!], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
            if activityError != nil {
                print("failure")
                return
            }
            if completed && activityType != nil {
                GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("social", action: activityType!, label: activityType!, value: 0).build() as [NSObject: AnyObject])
            }
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            activityVC.modalPresentationStyle = .Popover
            activityVC.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColorWheelSegue" {
            let vc = segue.destinationViewController as! OptionsViewController
            vc.currentColor = drawingView.currentColor
            vc.currentLineWidth = drawingView.currentLineWidth
            vc.selectedImage = drawingView.backgroundImage
        }
    }
    
    @IBAction func prepareForUnwind (segue: UIStoryboardSegue) {
        if let optionsVC = segue.sourceViewController as? OptionsViewController {
            drawingView.currentColor = optionsVC.currentColor
            drawingView.currentLineWidth = optionsVC.currentLineWidth
            if DrawingOptions.didSetBackground {
                drawingView.backgroundColor = DrawingOptions.backgroundColor
                DrawingOptions.didSetBackground = false
            }
            if let image = optionsVC.selectedImage {
                drawingView.backgroundImage = image
                drawingView.setNeedsDisplay()
            }
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("options", action: "color", label: optionsVC.currentColor.description, value: 0).build() as [NSObject: AnyObject])
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("options", action: "lineWidth", label: "lineWidth", value: optionsVC.currentLineWidth).build() as [NSObject: AnyObject])
        }
    }
}

