//
//  PlayerController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 16.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class PlayerController: NSObject {
    
    var player : SinglePlayer?
    lazy var shipPositionsTMP = [[String]]()
    
    func setup(shipPosKeys: [(Ship, [String])]) {
        player = SinglePlayer()
        player?.shipPosKeysPlayer = shipPosKeys
        fillShipPositionsTMP(shipPos: shipPosKeys)
        player?.setup()
    }
    
    //Checks the ai's attack
    func checkAIAttack(cellKey: String) -> Bool {
        
        for ship in player?.shipPosKeysPlayer ?? [] {
            
            //Ai attacks a cell which is contained in the player ship cells
            if ship.1.contains(cellKey) {
                player?.cellsLeft -= 1
                removeKeyFromTMPPositions(key: cellKey)
                return true
            }
        }
        return false
    }
    
    //Checks if ai has won
    func checkForAIWin() -> Bool {
        return player?.cellsLeft == 0
    }
    
    private func removeKeyFromTMPPositions(key: String) {
        
        var shipIndex = 0
        var keyIndex = 0
        
        //Search for the ship that contains the given key
        for i in 0..<shipPositionsTMP.count {
            
            if shipPositionsTMP[i].contains(key) {
                shipIndex = i
                guard let index = shipPositionsTMP[i].index(of: key) else {
                    return
                }
                keyIndex = index
            }
        }
        
        //Remove the given key from the tmp copy of the ship positions
        shipPositionsTMP[shipIndex].remove(at: keyIndex)
        
        //If ship array is empty -> ship is completely destroyed -> reduce value of shipsLeft
        if shipPositionsTMP[shipIndex].isEmpty {
            player?.shipsLeft -= 1
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name("shipsLeftOwn"), object: nil, userInfo: nil)
        }
    }
    
    /** Fills the temporary array, works like a copy to be able to do changes */
    private func fillShipPositionsTMP(shipPos: [(Ship, [String])]) {
    
        for shipPositions in shipPos {
            shipPositionsTMP.append(shipPositions.1)
        }
    }
}
