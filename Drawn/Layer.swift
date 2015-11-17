//
//  Layer.swift
//  Drawn
//
//  Created by Aaron Sky on 11/9/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Layer : NSObject, NSCoding {
    lazy var strokes : [Stroke] = [Stroke]()
    var strokeIndex : Int = 0
    
    func layer(ctx: CGContextRef, withFrame frame: CGRect) -> CGLayerRef? {
        let cLayer = CGLayerCreateWithContext(ctx, frame.size, nil)
        let layerCtx = CGLayerGetContext(cLayer)
        for stroke in strokes {
            CGContextSetStrokeColorWithColor(layerCtx, stroke.color.CGColor)
            CGContextSetLineWidth(layerCtx, stroke.path.lineWidth)
            CGContextAddPath(layerCtx, stroke.path.CGPath)
            CGContextStrokePath(layerCtx)
        }
        return cLayer!
    }
    
    override init() {
        print("Layer - \(__FUNCTION__) called")
        super.init()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        print("Layer - \(__FUNCTION__) called")
        super.init()
        if let _strokes = aDecoder.decodeObjectForKey("strokes") as? [Stroke] {
            strokes = _strokes
            strokeIndex = strokes.count
        }
        LayerEnum.initWithCoder(aDecoder)
        if let color = aDecoder.decodeObjectForKey("backgroundColor") as? UIColor {
            DrawingOptions.backgroundColor = color
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(strokes, forKey: "strokes")
        LayerEnum.encodeWithCoder(aCoder)
        aCoder.encodeObject(DrawingOptions.backgroundColor, forKey: "backgroundColor")
    }
    
    var isEmpty : Bool {
        if strokes.isEmpty {
            return false
        } else {
            for stroke in strokes {
                if stroke.path.empty {
                    return true
                }
            }
            return false
        }
    }
    
    func clear() {
        strokes.removeAll()
    }
    
    func strokeTo(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        if strokeIndex >= strokes.count {
            let stroke = Stroke(point: point, withColor: color, withLineWidth: lineWidth)
            strokes.append(stroke)
        } else {
            strokes[strokeIndex].strokeTo(point, withColor: color, withLineWidth: lineWidth)
        }
    }
    
    func finishStroke() {
        strokeIndex++
    }
    
    func popLast() -> Stroke? {
        if let stroke = strokes.popLast() {
            strokeIndex--;
            return stroke
        }
        return nil
    }
}