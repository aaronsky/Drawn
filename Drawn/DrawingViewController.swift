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
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var lineWidthStepper: UIStepper!
    @IBOutlet weak var strokeStepper: UIStepper!
    @IBOutlet weak var strokeValueLabel: UIBarButtonItem!
    
    var currentLineWidth : Float = 3.0
    
    //MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawingViewController.saveCurrentDrawing(_:)), name: "suspending", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawingViewController.updateUndoState(_:)), name: "updateUndoState", object: nil)

        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DrawingViewController.viewWasTapped(_:)))
        self.view.addGestureRecognizer(gesture)
        strokeValueLabel.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.blackColor()], forState: .Disabled)
        
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
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            promptSaveBeforeClear()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColorPopoverSegue" {
            let vc = segue.destinationViewController as! ColorPickerViewController
            vc.selectedColor = drawingView.currentColor
        } else if segue.identifier == "LayerPopoverSegue" {
            let vc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! LayerTableViewController
            vc.selectedImage = drawingView.backgroundImage
        }
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
    
    func viewWasTapped(gesture: UIGestureRecognizer) {
        if gesture.state == .Ended {
            if CGRectContainsPoint(toolbar.frame, gesture.locationInView(self.view)) {
                //don't
                print("shouldn't toggle")
            } else {
                toggleNavBar()
            }
        }
    }
    
    func toggleNavBar () {
        prefersStatusBarHidden()
        if navigationController != nil {
            if navigationController!.navigationBarHidden {
                navigationController?.setNavigationBarHidden(false, animated: false)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0, 0)
                })
            } else {
                navigationController?.setNavigationBarHidden(true, animated: false)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0, self.toolbar.frame.height)
                })
            }
        }
    }
    
    func promptSaveBeforeClear() {
        let alertVC = UIAlertController(title: "Delete Drawing", message: "Delete your beautiful drawing?", preferredStyle: .Alert)
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus != PHAuthorizationStatus.Denied {
            let saveAndDeleteAction = UIAlertAction(title: "Save and Delete", style: .Default) { (_) in
                GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("Delete", action: "Saved", label: "Saved before deleting", value: 0).build() as [NSObject: AnyObject])
                self.drawingView.toImage({ (image) -> Void in
                    if authStatus == PHAuthorizationStatus.Authorized {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        self.promptPreserveBackgroundImageForClear()
                    } else if authStatus == PHAuthorizationStatus.NotDetermined {
                        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                            if status == PHAuthorizationStatus.Authorized {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                self.promptPreserveBackgroundImageForClear()
                            }
                        })
                    }
                })
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
    
    //MARK: NSNotification
    func updateUndoState(notification: NSNotification?) {
        if let state = notification?.userInfo!["state"] as? Bool {
            undoButton.enabled = state
        } else {
            undoButton.enabled = drawingView.hasHistory
        }
    }
    
    //MARK: IBAction handlers
    @IBAction func undo(sender: UIBarButtonItem) {
        drawingView.undoStroke()
        updateUndoState(nil)
    }
    
    @IBAction func clearDrawing(sender: AnyObject) {
        promptSaveBeforeClear()
    }
    
    @IBAction func shareDrawing(sender: AnyObject) {
        let messageText = ""
        drawingView.toImage { (image) -> Void in
            let activityVC = UIActivityViewController(activityItems: [messageText, image], applicationActivities: nil)
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
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func strokeStepperValueChanged(sender: UIStepper) {
        drawingView.currentLineWidth = CGFloat(floor(sender.value))
        strokeValueLabel.title = "Stroke: \(drawingView.currentLineWidth)"
        GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("options", action: "lineWidth", label: "lineWidth", value: currentLineWidth).build() as [NSObject: AnyObject])
    }
    
    @IBAction func prepareForUnwind (segue: UIStoryboardSegue) {
        if let colorVC = segue.sourceViewController as? ColorPickerViewController {
            drawingView.currentColor = colorVC.selectedColor
            if DrawingOptions.didSetBackground {
                drawingView.backgroundColor = DrawingOptions.backgroundColor
                DrawingOptions.didSetBackground = false
            }
            GAHelper.trackerInstance?.send(GAIDictionaryBuilder.createEventWithCategory("options", action: "color", label: colorVC.selectedColor.description, value: 0).build() as [NSObject: AnyObject])
        } else if let layerVC = segue.sourceViewController as? LayerTableViewController {
            if let image = layerVC.selectedImage {
                drawingView.backgroundImage = image
                drawingView.setNeedsDisplay()
            }
        }
    }
}

