//
//  AIControllerTest.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.01.18.
//  Copyright © 2018 Patrick Niepel. All rights reserved.
//

import UIKit

class AIControllerTest: NSObject {
    
    let ai : AITest = AITest()
    var firstAttackInTurn : Bool = true
    var attackingBegan = false
    var waitingCounter = 0
    var counter = 0
    var lastAttackKey = ""
    
    var mTimer : Timer?
    
    
    init(difficulty: String) {
        ai.difficulty = difficulty
    }
    
    func setupAI(allKeys: [String], shipKeysPlayerString: [String], shipKeysPlayer: [(Ship, [String])], allKeysCoords: [(Int, Int)]) {
        ai.shipKeysPlayerString = shipKeysPlayerString
        ai.shipKeysPlayer = shipKeysPlayer
        createAI(allKeysCoords: allKeysCoords)
        setupShipKeys(allKeys: allKeys)
        setupLife()
    }
    
    private func createAI(allKeysCoords: [(Int, Int)]) {
        
        let positions = AICalculator().calculateShipPositions(allKeys: allKeysCoords)
        ai.shipKeys = positions
        //shipPositionsTMP = positions

    }
    
    private func setupShipKeys(allKeys: [String]) {
        ai.allKeys = allKeys
        //ai.noShipKeys = ShipKeyController().generateNoHitKeys(shipKeys: ai.shipKeys, allKeys: allKeys)
    }
    
    private func setupLife() {
        ai.shipsLeft = ai.shipKeys?.count ?? -1
        
        for ship in ai.shipKeys ?? [] {
            ai.cellsLeft += ship.count
        }
    }
    
    /** Sets the chances to hit a ship to a new value before every attack */
    private func setNewChanceValue() {
        
        let newChanceValues = AICalculator().generateNewChanceValue(difficulty: ai.difficulty ?? "")
        ai.chanceToAttack = newChanceValues.0
        ai.chanceToAttackAgain = newChanceValues.1
    }
    
    func checkForPlayerWin() -> Bool {
        return ai.cellsLeft == 0
    }
    
    /** Attacks player and waits several seconds if true for the next attack */
    func attackPlayer(wait: Bool) {
        
        //Waits a few seconds to attack again
        if wait {
            counter = AICalculator().generateTimerCounterForAttackAgain()
            
            //AI wont attack again when time to finish attack takes longer than turn
            if counter >= waitingCounter - 4 {
                return
            }
            startTimer()
        }
        else {
            //Starts attacking in this turn
            attackingBegan = true
            attack() //There is no lastAttackKey yet
        }
    }
    
    /* Gets the key that will be attacked and sends a notification */
    private func attack() {
        
        //Before every attack the chances to hit/not hit a ship will be calculated to provide variety
        setNewChanceValue()
        
        let attackedKey = AttackLogicController().getKeyToAttack(aiOpponent: ai, aLastAttackKey: lastAttackKey, firstAttackInTurn: firstAttackInTurn)
        let key = attackedKey.0
        let isHit = attackedKey.1
        
        let dataDict = ["aiAttacked" : key]
        
        //Wenn getroffen dann notification senden,
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name("aiAttacked"), object: nil, userInfo: dataDict)
        
        //The attacked key will become the lastAttackKey
        lastAttackKey = key
        firstAttackInTurn = false
        
        
        if !isHit {
            attackingBegan = false
        }
        //Remove key that lead to a hit
        //One key less to attack
        removeKeyFromAll(key: key)
    }
    
    private func startTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    /** Handles the timer to attack again */
    @objc func handleTimer() {
        
        counter -= 1
        
        if counter == 0 {
            mTimer?.invalidate()
            attack()
        }
    }
    
    func pauseResume(pause: Bool) {
        if pause {
            if mTimer != nil  && attackingBegan {
                mTimer?.invalidate()
            }
        }
        else {
            if attackingBegan {
                startTimer()
            }
        }
    }
    
    func checkIfPlayerHit(cellKey : String) -> Bool {
        
        var hit = false
        var cellIndex = 0
        var shipIndex = 0
        
        let count = ai.shipKeys?.count ?? 0
        
        for key in 0..<count {
            
            shipIndex = key
            
            //Player hits ship
            if ai.shipKeys?[key].contains(cellKey) ?? false {
                hit = true
                ai.cellsLeft -= 1
                
                guard let index = ai.shipKeys?[key].index(of: cellKey) else {
                    return false
                }
                cellIndex = index
                break
            }
        }
        
        if hit {
            removeShipKey(shipIndex: shipIndex, cellIndex: cellIndex)
        }

        return hit
    }
    
    private func removeShipKey(shipIndex: Int, cellIndex: Int) {
        ai.shipKeys?[shipIndex].remove(at: cellIndex)
        
        if ai.shipKeys?[shipIndex].count == 0 {
            ai.shipsLeft -= 1
            NotificationCenter.default.post(name: NSNotification.Name("shipsLeftOpponent"), object: nil)
        }
    }
    
    func removePlayerKey(key: String) {
        
        guard let index = ai.shipKeysPlayerString?.index(of: key) else {
            return
        }
        
        ai.shipKeysPlayerString?.remove(at: index)
        
        var cellIndex = 0
        var shipIndex = 0
        
        let count = ai.shipKeysPlayer?.count ?? 0
        
        for ship in 0..<count {
            
            shipIndex = ship
            
            //Player hits ship
            if ai.shipKeysPlayer?[ship].1.contains(key) ?? false {
                if let cellIndexSafe = ai.shipKeysPlayer?[ship].1.index(of: key) {
                    cellIndex = cellIndexSafe
                    break
                }
                
            }
        }
        ai.shipKeysPlayer?[shipIndex].1.remove(at: cellIndex)
    }
    
    func removeKeyFromAll(key: String) {
        guard let index = ai.allKeys?.index(of: key) else {
            return
        }
        ai.allKeys?.remove(at: index)
    }
    
    func getAICellsLeft() -> Int {
        return ai.cellsLeft
    }
    
    func getAIShipsLeft() -> Int {
        return ai.shipsLeft
    }
}
