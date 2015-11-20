//
//  MathHelper.swift
//  Drawn
//
//  Created by Aaron Sky on 11/18/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import Foundation

func scale(x:Float, minStart:Float, minEnd:Float, maxStart:Float, maxEnd:Float) -> Float {
    return ((x - minStart) / (minEnd - minStart)) * (maxEnd - maxStart) + maxStart
}