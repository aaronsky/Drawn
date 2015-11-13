//
//  DrawingOptions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class DrawingOptions : NSObject, NSCoding {
    var color : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var lineWidth : CGFloat = 3.0
    
    static var selectedLayer : LayerEnum = LayerEnum.Zero
    static var backgroundColor : UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static var didSetBackground : Bool = false
    
    override init() {
        print("DrawingOptions - \(__FUNCTION__) called")
        super.init()
    }
    
    init(color: UIColor, withLineWidth lineWidth: CGFloat) {
        print("DrawingOptions - \(__FUNCTION__) called")
        super.init()
        self.color = color
        self.lineWidth = lineWidth
    }
    
    required internal init(coder aDecoder: NSCoder) {
        print("DrawingOptions - \(__FUNCTION__) called")
        super.init()
        color = aDecoder.decodeObjectForKey("color") as! UIColor
        lineWidth = aDecoder.decodeObjectForKey("lineWidth") as! CGFloat
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(color, forKey: "color")
        aCoder.encodeObject(lineWidth, forKey: "lineWidth")
    }
    
    override func copy() -> AnyObject {
        let copy = DrawingOptions()
        copy.color = self.color.copy() as! UIColor
        copy.lineWidth = self.lineWidth
        return copy
    }
}