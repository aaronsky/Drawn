//
//  LayerEnum.swift
//  Drawn
//
//  Created by Aaron Sky on 11/12/15.
//  Copyright © 2015 Aaron Sky. All rights reserved.
//

import Foundation

enum LayerEnum: Int {
    case Zero = 0
    case One = 1
    case Two = 2
    case Background = 3
    
    static let allValues: [LayerEnum] = [.Zero, .One, .Two, .Background]
    static private var allDescriptions: [String] = ["Layer 0", "Layer 1", "Layer 2", "Background"]
    
    var description: String {
        get {
            switch self {
            case .Zero:
                return LayerEnum.allDescriptions[0]
            case .One:
                return LayerEnum.allDescriptions[1]
            case .Two:
                return LayerEnum.allDescriptions[2]
            case .Background:
                return LayerEnum.allDescriptions[3]
            }
        }
        set(newDescription) {
            switch self {
            case .Zero:
                LayerEnum.allDescriptions[0] = newDescription
                break
            case .One:
                LayerEnum.allDescriptions[1] = newDescription
                break
            case .Two:
                LayerEnum.allDescriptions[2] = newDescription
                break
            case .Background:
                LayerEnum.allDescriptions[3] = newDescription
                break
            }
        }
    }
    
    static func resetDescriptions() {
        LayerEnum.allDescriptions = ["Layer 0", "Layer 1", "Layer 2", "Background"]
    }
    
    static func initWithCoder(aDecoder: NSCoder) {
        if let descriptions = aDecoder.decodeObjectForKey("layer.descriptions") {
            LayerEnum.allDescriptions = descriptions as! [String]
        }
    }
    
    static func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(LayerEnum.allDescriptions, forKey: "layer.descriptions")
    }
}