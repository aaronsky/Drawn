//
//  Layer.swift
//  Drawn
//
//  Created by Aaron Sky on 11/9/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Layer : NSObject, NSCoding {
    var strokes : [Stroke] = [Stroke]()
    
    override init() {
        print("Layer - \(__FUNCTION__) called")
        super.init()
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        print("Layer - \(__FUNCTION__) called")
        self.init()
        if let _decoded = aDecoder.decodeObjectForKey("strokes") as? [Stroke] {
            strokes = _decoded
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
        if let stroke = strokes.last {
            if stroke.isStrokeComplete {
                startStroke(point, withColor: color, withLineWidth: lineWidth)
            } else {
                if stroke.color != color || stroke.path.lineWidth != lineWidth {
                    stroke.strokeTo(point, withColor: color, withLineWidth: lineWidth)
                } else {
                    stroke.strokeTo(point)
                }
            }
        } else {
            startStroke(point, withColor: color, withLineWidth: lineWidth)
        }
    }
    
    private func startStroke(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        let stroke = Stroke(point: point, withColor: color, withLineWidth: lineWidth)
        self.strokes.append(stroke)
    }
    
    func finishStroke() {
        if let stroke = strokes.last {
            if stroke.empty {
                strokes.removeLast()
            } else {
                stroke.isStrokeComplete = true
            }
        }
    }
    
    func popLast() -> Stroke? {
        if let stroke = strokes.popLast() {
            return stroke
        }
        return nil
    }
    
    override var description : String {
        return "Layer contains \(strokes.count) strokes"
    }
}