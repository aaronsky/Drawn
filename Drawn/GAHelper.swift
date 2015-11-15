//
//  GAnalyticsHelper.swift
//  Drawn
//
//  Created by Aaron Sky on 11/14/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import Foundation

/**
 * Drawing
 *   Stroke counts
 *   Stroke lengths
 *   Stroke distribution across layers
 * Sharing
 *   What services are popular?
 *   After sharing, are users saving?
 * Deleting
 *   Saving?
 * Options
 *   Color
 *       RGB
 *       HSV
 *       Most popular color
 *   Line Width
 *       Most popular line width (if higher, consider raising limit)
 *   Layers
 *       Are people selecting layers
 *       Are people renaming layers
 *       Are people setting a new background color
 *       Are people setting a background image?
 */

class GAHelper {
    
    static private var tracker: GAITracker?
    
    private init() { }
    
    class func setup() -> Bool {
        if let path = NSBundle.mainBundle().pathForResource("GoogleService-Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                if dict.objectForKey("IS_ANALYTICS_ENABLED") as! Bool {
                    GAI.sharedInstance().trackUncaughtExceptions = true
                    GAI.sharedInstance().dispatchInterval = 20
                    GAI.sharedInstance().logger.logLevel = .Verbose
                    GAHelper.tracker = GAI.sharedInstance().trackerWithTrackingId(dict.objectForKey("TRACKING_ID") as! String)
                    return true
                }
            }
        }
        return false
    }
    
    static var trackerInstance: GAITracker? {
        return tracker
    }
    
    func report(category: String, withAction action: String, withLabel label: String, andValue value: NSNumber!) {
        let gai = GAI.sharedInstance()
        let tracker = gai.defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build() as [NSObject: AnyObject])
    }
}