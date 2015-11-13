//
//  LayerTableViewController.swift
//  Drawn
//
//  Created by Aaron Sky on 11/12/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import UIKit

class LayerTableViewController: UITableViewController {

    //MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: DrawingOptions.selectedLayer.rawValue, inSection: 0))
        cell?.accessoryType = .Checkmark
    }
    
    
    //MARK: UITableViewController overrides
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cellName = cell?.reuseIdentifier {
            switch cellName {
            case "Layer0Cell": DrawingOptions.selectedLayer = LayerEnum.Zero; break
            case "Layer1Cell": DrawingOptions.selectedLayer = LayerEnum.One; break
            case "Layer2Cell": DrawingOptions.selectedLayer = LayerEnum.Two; break
            case "BackgroundCell": DrawingOptions.didSetBackground = true; break
            default: DrawingOptions.selectedLayer = LayerEnum.Zero; break
            }
        }
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}
