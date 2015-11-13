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
    lazy var history : [LayerEnum] = [LayerEnum]()
    var options : DrawingOptions = DrawingOptions()
    
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
    func createImageFromContext () -> UIImage? {
        print("create image from context")
        UIGraphicsBeginImageContext(frame.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func clear () {
        print("clear the screen")
        DrawingOptions.selectedLayer = LayerEnum.Zero
        history.removeAll()
        for layer in layers {
            layer.clear()
        }
        setNeedsDisplay()
    }
    
    func undoStroke () {
        if let layerIndex = history.last {
            if let _ = layers[layerIndex.rawValue].popLast() {
                history.removeLast()
                setNeedsDisplay()
            }
        }
    }
    
    func transpose(orientation: Orientation) {
        for layer in layers {
            if orientation == .Portrait {
                layer.transposePortrait()
            } else if orientation == .Landscape {
                layer.transposeLandscape()                
            }
        }
    }
    
    //MARK: UIView overrides
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        for layer in layers {
            for stroke in layer.strokes {
                CGContextSetStrokeColor(ctx, CGColorGetComponents(stroke.options.color.CGColor))
                CGContextSetLineWidth(ctx, stroke.options.lineWidth)
                CGContextSetLineJoin(ctx, .Round)
                CGContextSetLineCap(ctx, .Round)
                
                for var i = 0; i < stroke.points.count - 1; i++ {
                    let point1 = stroke.points[i]
                    let point2 = stroke.points[i+1]
                    CGContextMoveToPoint(ctx, point1.x, point1.y);
                    CGContextAddLineToPoint(ctx, point2.x, point2.y)
                    CGContextStrokePath(ctx)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            layers[DrawingOptions.selectedLayer.rawValue].strokeTo(point, withOptions: options)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            layers[DrawingOptions.selectedLayer.rawValue].strokeTo(point, withOptions: options)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        layers[DrawingOptions.selectedLayer.rawValue].finishStroke()
        history.append(DrawingOptions.selectedLayer)
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
}
