//
//  UIViewControllerExtensions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/14/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

extension UIBezierPath {
    var elements : [CGPathElement] {
        var pathElements = [CGPathElement]()
        withUnsafeMutablePointer(&pathElements) { elementsPointer in
            CGPathApply(CGPath, elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = CGPathElement(type: nextElementPointer.memory.type, points: nextElementPointer.memory.points)
                let elementsPointer = UnsafeMutablePointer<[CGPathElement]>(userInfo)
                elementsPointer.memory.append(nextElement)
            }
        }
        return pathElements
    }
}
