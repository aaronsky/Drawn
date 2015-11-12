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
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: DrawingOptions.selectedLayer, inSection: 0))
        cell?.accessoryType = .Checkmark
    }
    
    
    //MARK: UITableViewController overrides
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cellName = cell?.reuseIdentifier {
            switch cellName {
            case "Layer0Cell": DrawingOptions.selectedLayer = 0; break
            case "Layer1Cell": DrawingOptions.selectedLayer = 1; break
            case "Layer2Cell": DrawingOptions.selectedLayer = 2; break
            case "BackgroundCell": DrawingOptions.selectedLayer = 3; break
            default: DrawingOptions.selectedLayer = 0; break
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
