//
//  ShipKeyController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.01.18.
//  Copyright © 2018 Patrick Niepel. All rights reserved.
//

import UIKit

class ShipKeyController: NSObject {
    
    
    func generateNoHitKeys(shipKeys: [(Ship, [String])], allKeys: [String]) -> [String] {
        
        let shipKeysString = convertShipTupelToArray(shipKeys: shipKeys)
        
        let allKeysSet = Set(allKeys)
        let shipKeysSet = Set(shipKeysString)
        //All keys that won't lead to hits
        let noHitKeysSet = allKeysSet.subtracting(shipKeysSet)
        
        return Array(noHitKeysSet)
    }
    
    func convertShipTupelToArray(shipKeys: [(Ship, [String])]) -> [String] {
        
        var shipKeyArray = [String]()
        
        for ship in shipKeys {
            for key in ship.1 {
                shipKeyArray.append(key)
            }
        }
        
        return shipKeyArray
    }
}
