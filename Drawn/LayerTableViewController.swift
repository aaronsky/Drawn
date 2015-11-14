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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedImageFromPicker:", name: "selectedImageFromPicker", object: nil)
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: DrawingOptions.selectedLayer.rawValue, inSection: 0)) {
            cell.accessoryType = .Checkmark
        }
    }
    
    //MARK: NSNotification
    func selectedImageFromPicker(notification: NSNotification?) {
        if let image: UIImage = notification?.userInfo!["image"] as? UIImage {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) {
                cell.imageView?.image = image
                tableView.setEditing(false, animated: true)
            }
        }
    }
    
    //MARK: UITableViewController overrides
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.text = LayerEnum.allValues[indexPath.row].description
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cellName = cell?.reuseIdentifier {
            switch cellName {
            case "Layer0Cell": DrawingOptions.selectedLayer = LayerEnum.Zero; break
            case "Layer1Cell": DrawingOptions.selectedLayer = LayerEnum.One; break
            case "Layer2Cell": DrawingOptions.selectedLayer = LayerEnum.Two; break
            case "BackgroundCell":
                DrawingOptions.didSetBackground = true;
                NSNotificationCenter.defaultCenter().postNotificationName("disableAlphaControls", object: nil)
                break
            default: DrawingOptions.selectedLayer = LayerEnum.Zero; break
            }
        }
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.reuseIdentifier == "BackgroundCell" {
                NSNotificationCenter.defaultCenter().postNotificationName("enableAlphaControls", object: nil)
            }
            cell.accessoryType = .None
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.reuseIdentifier == "BackgroundCell" {
                let chooseImageAction = UITableViewRowAction(style: .Default, title: "Choose Image") { (action, indexPath) in
                    NSNotificationCenter.defaultCenter().postNotificationName("loadBackgroundImage", object: nil)
                }
                actions.append(chooseImageAction)
            } else {
                let renameLayerAction = UITableViewRowAction(style: .Default, title: "Rename") { (action, indexPath) in
                    self.editLayerName(indexPath)
                    tableView.setEditing(false, animated: true)
                }
                actions.append(renameLayerAction)
            }
        }
        return actions
    }
    
    func editLayerName(indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let title = cell.textLabel?.text ?? "this layer"
            var textField: UITextField?
            let alertVC = UIAlertController(title: "Edit name", message: "Enter a new name for \(title)", preferredStyle: .Alert)
            alertVC.addTextFieldWithConfigurationHandler({ (field) in
                field.placeholder = "Layer name"
                textField = field
            })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                textField?.resignFirstResponder()
                let name = textField?.text
                cell.textLabel?.text = name
                if var layer = LayerEnum(rawValue: indexPath.row) {
                    layer.description = name!
                }
            }))
            presentViewController(alertVC, animated: true, completion: nil)
        }
    }
}
