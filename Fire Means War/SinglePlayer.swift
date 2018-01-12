//
//  SinglePlayer.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 16.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class SinglePlayer: NSObject {
    
    var cellsLeft = 0
    
    //All ship keys if player
    var shipPosKeysPlayer : [(Ship, [String])]! {
        didSet {
            shipsLeft = shipPosKeysPlayer.count
        }
    }
    var allPlayerKeys = [String]()
    
    var shipsLeft = 0
    
    func setup() {
        setupLife()
        setupPlayerKeys()
    }
    
    //Sets the player life according to the number of existing keys of the player's ships
    fileprivate func setupLife() {
        
        var counter = 0
        
        for shipKeys in shipPosKeysPlayer {
            counter += shipKeys.1.count
        }
        
        cellsLeft = counter
    }
    
    //Appends all keys of the player's ships to one single list to get better access
    fileprivate func setupPlayerKeys() {
        
        for ship in shipPosKeysPlayer {
            for key in ship.1 {
                allPlayerKeys.append(key)
            }
        }
    }

}
