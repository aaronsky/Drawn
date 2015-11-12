//
//  DrawingOptions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/8/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

struct DrawingOptions {
    var color : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var lineWidth : CGFloat = 3.0
    static var selectedLayer : Int = 0
    static var backgroundColor : UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
}