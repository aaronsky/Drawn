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
    lazy var color : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    override init() {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
    }
    
    init(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
        strokeTo(point, withColor: color, withLineWidth: lineWidth)
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        print("Stroke - \(__FUNCTION__) called")
        super.init()
        if let _path = aDecoder.decodeObjectForKey("path") as? UIBezierPath {
            path = _path
        }
        if let _color = aDecoder.decodeObjectForKey("color") as? UIColor {
            color = _color
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(path, forKey: "path")
        aCoder.encodeObject(color, forKey: "color")
    }
    
    func strokeTo(point: CGPoint, withColor color: UIColor, withLineWidth lineWidth: CGFloat) {
        self.color = color
        path.lineWidth = lineWidth
        if path.empty {
            path.moveToPoint(point)
        } else {
            path.addLineToPoint(point)
        }
    }
}