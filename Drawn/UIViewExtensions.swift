//
//  UIViewExtensions.swift
//  Drawn
//
//  Created by Aaron Sky on 11/19/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

extension UIView {
    func toImage() -> UIImage {
        print("create image from context")
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func toImage(completion: (result: UIImage) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            print("create image from context")
            UIGraphicsBeginImageContext(self.bounds.size)
            self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(result: image)
        }
    }
}