//
//  UINavigationControllerExtensions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/14/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        return (visibleViewController?.shouldAutorotate())!
    }
}