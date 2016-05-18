//
//  Stroke.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class Stroke : NSObject, NSCoding {
    lazy var path : UIBezierPath = UIBezierPath()
    var pointCount : Int = 0
    lazy var color : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var isStrokeComplete : Bool = false
    
    var empty : Bool {
        return path.empty || pointCount <= 1
    }
    
    override init() {
        print("Stroke - \(#function) called")
        super.init()
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
    }
    
    init(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        print("Stroke - \(#function) called")
        super.init()
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
        path.moveToPoint(point)
        pointCount += 1
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        print("Stroke - \(#function) called")
        super.init()
        if let _path = aDecoder.decodeObjectForKey("path") as? UIBezierPath {
            path = _path
            pointCount = path.elements.count + 1
        }
        if let _color = aDecoder.decodeObjectForKey("color") as? UIColor {
            color = _color
        }
        if let _complete = aDecoder.decodeObjectForKey("complete") as? Bool {
            isStrokeComplete = _complete
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(path, forKey: "path")
        aCoder.encodeObject(color, forKey: "color")
        aCoder.encodeObject(isStrokeComplete, forKey: "complete")
    }
    
    func strokeTo(point: CGPoint) {
        path.addLineToPoint(point)
        pointCount += 1
    }
    
    func strokeTo(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        self.color = color
        path.lineWidth = lineWidth
        strokeTo(point)
    }
}