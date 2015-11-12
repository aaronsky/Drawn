//
//  Stroke.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Stroke {
    lazy var points : [CGPoint] = [CGPoint]()
    var options : DrawingOptions = DrawingOptions()
    
    func strokeTo(point: CGPoint) {
        points.append(point)
    }
}