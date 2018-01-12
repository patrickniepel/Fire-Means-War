//
//  SinglePlayerControllerTest.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.01.18.
//  Copyright © 2018 Patrick Niepel. All rights reserved.
//

import UIKit

class SinglePlayerControllerTest: NSObject {
    
    let singleplayer : SingleplayerTest = SingleplayerTest()
    
    init(playerShipKeys: [(Ship, [String])]) {
        singleplayer.shipKeys = playerShipKeys
    }
    
    func setupSingleplayer(allKeys: [String]) {
        setupNoShipKeys(allKeys: allKeys)
        setupLife()
    }
    
    private func setupNoShipKeys(allKeys: [String]) {
        singleplayer.noShipKeys = ShipKeyController().generateNoHitKeys(shipKeys: singleplayer.shipKeys, allKeys: allKeys)
    }
    
    private func setupLife() {
        singleplayer.shipsLeft = singleplayer.shipKeys.count
        
        for ship in singleplayer.shipKeys {
            singleplayer.cellsLeft += ship.1.count
        }
    }
    
    func getShipKeysPlayerStringForAI() -> [String] {
        return ShipKeyController().convertShipTupelToArray(shipKeys: singleplayer.shipKeys)
    }
    
    func getShipKeysPlayerForAI() -> [(Ship, [String])] {
        return singleplayer.shipKeys
    }
    
    func checkForAIWin() -> Bool {
        return singleplayer.cellsLeft == 0
    }
    
    func checkIfAIHit(cellKey : String) -> Bool {
        
        var hit = false
        var cellIndex = 0
        var shipIndex = 0
        
        for key in 0..<singleplayer.shipKeys.count {
            
            shipIndex = key
            
            //Player hits ship
            if singleplayer.shipKeys[key].1.contains(cellKey) {
                hit = true
                singleplayer.cellsLeft -= 1
                cellIndex = singleplayer.shipKeys[key].1.index(of: cellKey)!
                break
            }
        }
        
        if hit {
            removeShipKey(shipIndex: shipIndex, cellIndex: cellIndex)
        }
        
        return hit
    }
    
    private func removeShipKey(shipIndex: Int, cellIndex: Int) {
        singleplayer.shipKeys[shipIndex].1.remove(at: cellIndex)
        
        if singleplayer.shipKeys[shipIndex].1.count == 0 {
            singleplayer.shipsLeft -= 1
            NotificationCenter.default.post(name: NSNotification.Name("shipsLeftOwn"), object: nil)
        }
    }
    
    func getPlayerCellsLeft() -> Int {
        return singleplayer.cellsLeft
    }
    
    func getPlayerShipsLeft() -> Int {
        return singleplayer.shipsLeft
    }
}
