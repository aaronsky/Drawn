//
//  DrawingView.swift
//  Drawn
//
//  Created by Aaron Sky on 11/7/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    var layers : [Layer] = [Layer(), Layer(), Layer()]
    var currentColor : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var currentLineWidth : CGFloat = 3.0
    var backgroundImage : UIImage?
    private lazy var history : [LayerEnum] = [LayerEnum]()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = DrawingOptions.backgroundColor
    }
    
    //MARK: DrawingView functions
    func clear (clearImage flag: Bool = true) {
        print("clear the screen")
        LayerEnum.resetDescriptions()
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        if flag {
            backgroundImage = nil
        }
        DrawingOptions.selectedLayer = LayerEnum.Zero
        history.removeAll()
        for layer in layers {
            layer.clear()
        }
        setNeedsDisplay()
    }
    
    var hasHistory : Bool {
        return !history.isEmpty
    }
    
    func undoStroke () {
        if let layerIndex = history.last {
            if let _ = layers[layerIndex.rawValue].popLast() {
                history.removeLast()
                setNeedsDisplay()
            }
        }
    }
    
    func hasStartedDrawing() -> Bool {
        for layer in layers {
            if layer.isEmpty {
                return true
            }
        }
        return false
    }
    
    //MARK: UIView overrides
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        if let image = backgroundImage {
            CGContextSaveGState(ctx);
            CGContextTranslateCTM(ctx, 0.0, frame.height)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            CGContextDrawImage(ctx, frame, image.CGImage)
            CGContextRestoreGState(ctx)
        }
        for layer in layers {
            let layerCG = layer.layer(ctx!, withFrame: frame)
            CGContextDrawLayerInRect(ctx, frame, layerCG)
        }        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            layers[DrawingOptions.selectedLayer.rawValue].strokeTo(point, withColor: currentColor, withLineWidth: currentLineWidth)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            layers[DrawingOptions.selectedLayer.rawValue].strokeTo(point, withColor: currentColor, withLineWidth: currentLineWidth)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        layers[DrawingOptions.selectedLayer.rawValue].finishStroke()
        history.append(DrawingOptions.selectedLayer)
        NSNotificationCenter.defaultCenter().postNotificationName("updateUndoState", object: self, userInfo: ["state":true])
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
}
