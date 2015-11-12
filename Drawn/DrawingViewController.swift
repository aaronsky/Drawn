//
//  ViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/7/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var drawingView: DrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.hidesBarsOnTap = true
        navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: "toggleNavBar:")
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    func toggleNavBar (tap: UITapGestureRecognizer) {
        prefersStatusBarHidden()
    }
    
    func promptClear() {
        let deleteWithoutSavingAction = UIAlertAction(title: "Delete Without Saving", style: .Destructive) { (_) in
            self.drawingView.clear()
        }
        let saveAndDeleteAction = UIAlertAction(title: "Save and Delete", style: .Default) { (_) in
            let image = self.drawingView.createImageFromContext()
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            self.drawingView.clear()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        let alertVC = UIAlertController(title: "Delete Drawing", message: "Delete your beautiful drawing?", preferredStyle: .Alert)
        alertVC.addAction(saveAndDeleteAction)
        alertVC.addAction(deleteWithoutSavingAction)
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true) { () in }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            promptClear()
        }
    }
    
    @IBAction func undo(sender: AnyObject) {
        self.drawingView.undoStroke()
    }
    
    @IBAction func clearDrawing(sender: AnyObject) {
        promptClear()
    }
    
    @IBAction func shareDrawing(sender: AnyObject) {
        let image = drawingView.createImageFromContext()
        let messageText = "woah"
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
            if optionsVC.didSetBackground {
                DrawingOptions.selectedLayer = 0
            }
        }
    }
}

