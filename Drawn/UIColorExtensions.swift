//
//  UIColorExtensions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/19/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

extension UIColor {
    func inverse() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a:CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a)
        }
        return self
    }
}