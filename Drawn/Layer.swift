//
//  Layer.swift
//  Drawn
//
//  Created by Aaron Sky on 11/9/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Layer {
    lazy var strokes : [Stroke] = [Stroke]()
    var strokeIndex : Int = 0
    
    func clear() {
        for stroke in strokes {
            stroke.points.removeAll()
        }
    }
    
    func strokeTo(point: CGPoint, withForce force: CGFloat = 1.0, withOptions options: DrawingOptions = DrawingOptions()) {
        if strokeIndex >= strokes.count {
            strokes.append(Stroke())
        }
        
        strokes[strokeIndex].options = options
        strokes[strokeIndex].options.lineWidth *= force
        strokes[strokeIndex].strokeTo(point)
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