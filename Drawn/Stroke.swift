//
//  Stroke.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Stroke : NSObject, NSCoding {
    lazy var points : [CGPoint] = [CGPoint]()
    var options : DrawingOptions = DrawingOptions()
    
    override init() {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
    }
    
    init(point: CGPoint, withOptions options: DrawingOptions) {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
        strokeTo(point, withOptions: options)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
        let count = aDecoder.decodeIntegerForKey("points.count")
        for var i in 0 ..< count {
            let point = aDecoder.decodeCGPointForKey("points[\(i)]")
            points.append(point)
        }
        options = aDecoder.decodeObjectForKey("options") as! DrawingOptions
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(points.count, forKey: "points.count")
        for var i in 0 ..< points.count {
            aCoder.encodeCGPoint(points[i], forKey: "points[\(i)]")
        }
        aCoder.encodeObject(options, forKey: "options")
    }
    
    func strokeTo(point: CGPoint, withOptions options: DrawingOptions) {
        points.append(point)
        self.options = options
    }
}