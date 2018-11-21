//
//  AI.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class AI {
    
    var difficulty : String?
    
    //All available keys of the gamefield / (x,y)
    var allKeys = [(Int, Int)]()
    var allKeysString = [String]()
    
    //All ship keys of ai
    var shipPosKeys : [[String]]? {
        didSet {
            shipsLeft = shipPosKeys?.count ?? -1
        }
    }
    var shipsLeft : Int = 0
    
    //All ship keys if player
    var shipPosKeysPlayer : [(Ship, [String])]?
    var allPlayerKeys = [String]()
    
    //When 0, player wins
    var cellsLeft : Int = 0
    
    
    var chanceToAttack : Int = 50
    var chanceToAttackAgain : Int = 50
    
    func setup() {
        setupAllKeys()
        setupLife()
        setupPlayerKeys()
    }
    
    /** Generates all keys of the game field */
    fileprivate func setupAllKeys() {
        
        let field = Field()
        
        for j in 0..<field.cellsPerRow {
            for i in 0..<field.cellsPerRow {
                
                allKeys.append((i, j))
                
                let key = "\(i)|\(j)"
                allKeysString.append(key)
            }
        }
    }
    
    /** Sets the ai life according to the number of existing keys of the player's ships */
    fileprivate func setupLife() {
        
        var counter = 0
        
        for shipKeys in shipPosKeysPlayer ?? [] {
            counter += shipKeys.1.count
        }
        
        cellsLeft = counter
    }
    
    /** Appends all keys of the player's ships to a single list to get better access */
    fileprivate func setupPlayerKeys() {
        
        for ship in shipPosKeysPlayer ?? [] {
            for key in ship.1 {
                allPlayerKeys.append(key)
            }
        }
    }
    
    /** Erases the given key in the array of the player's ship keys */
    func removePlayerKey(key: String) {
        
        if let index = allPlayerKeys.index(of: key) {
            allPlayerKeys.remove(at: index)
        }
    }
    
    /** Erases the given key in the array of all available keys */
    func removeAllKey(key: String) {
        
        if let index = allKeysString.index(of: key) {
            allKeysString.remove(at: index)
        }
    }
}
