//
//  AIController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class AIController: NSObject {
    
    var ai : AI!
    var aiCalc : AICalculator!
    var playerCtrl : PlayerController!
    var logicCtrl : AttackLogicController!
    var counter = 0
    var lastAttackKey = ""
    var firstAttackInTurn = true
    var waitingCounterTVC = 0
    var mTimer : Timer!
    var attackingBegan = false
    lazy var shipPositionsTMP = [[String]]()
    
    init(difficulty: String, playerShips: [(Ship, [String])]) {
        super.init()
        
        aiCalc = AICalculator()
        
        ai = AI()
        playerCtrl = PlayerController()
        
        ai.shipPosKeysPlayer = playerShips
        ai.setup()
        
        playerCtrl.setup(shipPosKeys: playerShips)
        
        setup(difficulty: difficulty)
        
        logicCtrl = AttackLogicController()
        
        print("AICellsLeftStart", ai.cellsLeft)
        print("PlayerCellsLeftStart", playerCtrl.player.cellsLeft)
    }
    
    fileprivate func setup(difficulty: String) {
        
        ai.difficulty = difficulty
        
        let positions = aiCalc.calculateShipPositions(ai: ai)
        ai.shipPosKeys = positions
        shipPositionsTMP = positions
        print(positions)
    }
    
    fileprivate func startTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    /** Attacks player and waits several seconds if true for the next attack */
    func attackPlayer(wait: Bool) {
        
        //Waits a few seconds to attack again
        if wait {
            counter = aiCalc.generateTimerCounterForAttackAgain()
            
            //AI wont attack again when time to finish attack takes longer than turn 
            if counter >= waitingCounterTVC - 4 {
                return
            }
            startTimer()
        }
        else {
            //Starts attacking in this turn
            attackingBegan = true
            attackPlayer() //There is no lastAttackKey yet
        }
    }
    
    /** Handles the timer to attack again */
    @objc func handleTimer() {
        
        counter -= 1
        
        if counter == 0 {
            mTimer.invalidate()
            attackPlayer()
        }
    }
    
    /* Gets the key that will be attacked and sends a notification */
    fileprivate func attackPlayer() {
        
        //Before every attack the chances to hit/not hit a ship will be calculated to provide variety
        setNewChanceValue()
        
        let attackedKey = logicCtrl.getKeyToAttack(aiOpponent: ai, aLastAttackKey: lastAttackKey, firstAttackInTurn: firstAttackInTurn)
        let key = attackedKey.0
        let isHit = attackedKey.1
        
        let dataDict = ["aiAttacked" : key]
        
        //Wenn getroffen dann notification senden,
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name("aiAttacked"), object: nil, userInfo: dataDict)
        
        //The attacked key will become the lastAttackKey
        lastAttackKey = key
        firstAttackInTurn = false
        
        //Remove key that lead to a hit
        if isHit {
            ai.removePlayerKey(key: key)
            print("PlayerKeysCount", ai.allPlayerKeys.count)
            print("PlayerKeysÜbrig", ai.allPlayerKeys)
            print("RemovedPlayerKey", key)
        }
        //Remove key that did not lead to a hit
        else {
            //Wont attack anymore in this turn
            attackingBegan = false
            ai.removeAllKey(key: key)
        }
    }
    
    func pauseResumeAI(pause: Bool) {
        
        if pause {
            if mTimer != nil  && attackingBegan {
                mTimer.invalidate()
            }
        }
        else {
            if attackingBegan {
                startTimer()
            }
        }
    }
    
    /** Sets the chances to hit a ship to a new value before every attack */
    fileprivate func setNewChanceValue() {
        
        let newChanceValues = aiCalc.generateNewChanceValue(difficulty: ai.difficulty)
        ai.chanceToAttack = newChanceValues.0
        ai.chanceToAttackAgain = newChanceValues.1
    }
    
    /** Checks if player has won */
    func checkForPlayerWin() -> Bool {
        return ai.cellsLeft == 0
    }
    
    /** Checks the player's attack */
    func checkPlayerAttack(cellKey: String) -> Bool {
        
        for ship in ai.shipPosKeys {
            
            //Player attack a cell which is contained in the ai ship cells
            if ship.contains(cellKey) {
                ai.cellsLeft -= 1
                removeKeyFromTMPPositions(key: cellKey)
                print("AICellsLeft", ai.cellsLeft)
                return true
            }
        }
        return false
    }
    
    fileprivate func removeKeyFromTMPPositions(key: String) {
        
        var shipIndex = 0
        var keyIndex = 0
        
        //Search for the ship that contains the given key
        for i in 0..<shipPositionsTMP.count {
            
            if shipPositionsTMP[i].contains(key) {
                shipIndex = i
                keyIndex = shipPositionsTMP[i].index(of: key)!
            }
        }
        
        //Remove the given key from the tmp copy of the ship positions
        shipPositionsTMP[shipIndex].remove(at: keyIndex)
        
        //If ship array is empty -> ship is completely destroyed -> reduce value of shipsLeft
        if shipPositionsTMP[shipIndex].isEmpty {
            ai.shipsLeft -= 1
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name("shipsLeftOpponent"), object: nil, userInfo: nil)
        }
    }
    
    func getCounterForAttack() -> Int {
        return aiCalc.generateTimerCounterForAttack()
    }
    
//____________________________________________________________________PlayerController
    
    func checkAIAttack(cellKey: String) -> Bool {
        return playerCtrl.checkAIAttack(cellKey: cellKey)
    }
    
    func checkForAIWin() -> Bool {
        return playerCtrl.checkForAIWin()
    }
}
