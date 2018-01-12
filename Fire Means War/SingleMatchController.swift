//
//  SingleMatchController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.01.18.
//  Copyright © 2018 Patrick Niepel. All rights reserved.
//

import UIKit

class SingleMatchController: NSObject {
    
    var aiCtrl : AIControllerTest
    var spCtrl : SinglePlayerControllerTest
    
    var allKeys = [(Int, Int)]()
    var allKeysString = [String]()
    
    
    init(difficulty: String, playerShipKeys: [(Ship, [String])]) {
        aiCtrl = AIControllerTest(difficulty: difficulty)
        spCtrl = SinglePlayerControllerTest(playerShipKeys: playerShipKeys)
    }
    
    func createMatch() {
        setupAllKeys()
        spCtrl.setupSingleplayer(allKeys: allKeysString)
        aiCtrl.setupAI(allKeys: allKeysString, shipKeysPlayerString: spCtrl.getShipKeysPlayerStringForAI(), shipKeysPlayer: spCtrl.getShipKeysPlayerForAI(), allKeysCoords: allKeys)
    }
    
    /** Generates all keys of the game field */
    private func setupAllKeys() {
        
        let field = Field()
        
        for j in 0..<field.cellsPerRow {
            for i in 0..<field.cellsPerRow {
                
                allKeys.append((i, j))
                
                let key = "\(i)|\(j)"
                allKeysString.append(key)
            }
        }
    }
    
    func setFirstAttackInTurn(firstAttack: Bool) {
        aiCtrl.firstAttackInTurn = firstAttack
    }
    
    func setWaitingCounter(counter: Int) {
        aiCtrl.waitingCounter = counter
    }
    
    func getAICellsLeft() -> Int {
        return aiCtrl.getAICellsLeft()
    }
    
    func getAIShipsLeft() -> Int {
        return aiCtrl.getAIShipsLeft()
    }
    
    func getCounterForAttack() -> Int {
        return AICalculator().generateTimerCounterForAttack()
    }
    
    func attackPlayer(wait: Bool) {
        aiCtrl.attackPlayer(wait: wait)
    }
    
    func checkAIAttack(cellKey : String) -> Bool {
        return spCtrl.checkIfAIHit(cellKey: cellKey)
    }
    
    func pauseResumeAI(pause: Bool) {
        aiCtrl.pauseResume(pause: pause)
    }
    
    func checkForAIWin() -> Bool {
        return spCtrl.checkForAIWin()
    }
    
    func removeAttackedKeyFromAIPlayerKeysArray(key: String) {
        aiCtrl.removePlayerKey(key: key)
    }
    
    ////////////////////////////////////////////////////////////////
    
    func checkForPlayerWin() -> Bool {
        return aiCtrl.checkForPlayerWin()
    }
    
    func checkPlayerAttack(cellKey: String) -> Bool {
        return aiCtrl.checkIfPlayerHit(cellKey: cellKey)
    }
    
    func getPlayerCellsLeft() -> Int {
        return spCtrl.getPlayerCellsLeft()
    }
    
    func getPlayerShipsLeft() -> Int {
        return spCtrl.getPlayerShipsLeft()
    }
    
    

}
