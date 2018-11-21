//
//  AttackLogicController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 05.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class AttackLogicController: NSObject {
    
    var ai : AITest?
    var lastAttackKey = ""
    var lastAttackWasHit = false
    
    func getKeyToAttack(aiOpponent: AITest, aLastAttackKey: String, firstAttackInTurn: Bool) -> (String, Bool) {
        
        ai = aiOpponent
        
        guard let ai = ai else {
            return ("", false)
        }
        
        lastAttackKey = aLastAttackKey
        
        var keyToAttack = ""
        let percentage = generatePercentageToAttack()
        
        //First attack
        if firstAttackInTurn {
            
            //Hit // First attack has a lower chance to hit, but will attack near the last attack
            if percentage <= ai.chanceToAttack {
                keyToAttack = getHitAgainKey()
                lastAttackWasHit = true
            }
            //No hit
            else {
                keyToAttack = getNoHitKey()
                lastAttackWasHit = false
            }
        }
        //Attack again
        else {
            
            //Hit //Second and more attacks per turn have a higher chance to hit, cause the position of the attacked ship is known
            if percentage <= ai.chanceToAttackAgain {
                keyToAttack = getHitAgainKey()
                lastAttackWasHit = true
            }
            //No hit
            else {
                keyToAttack = getNoHitKey()
                lastAttackWasHit = false
            }
        }
        
        return (keyToAttack, lastAttackWasHit)
    }
    
    /** Returns the key for a successfull attack for the first attack of the turn */
    fileprivate func getHitKey() -> String {
        
        guard let ai = ai else {
            return ""
        }
        
        var randomIndex = 0
        
        while randomIndex >= ai.shipKeysPlayerString?.count ?? 0 {
            randomIndex = generateRandomAttackKey(value: ai.shipKeysPlayer?.count ?? 0)
        }
        
        return ai.shipKeysPlayerString?[randomIndex] ?? ""
    }
    
    /** Returns the for a another succesfull attack (used when ai attacks multiple times) */
    fileprivate func getHitAgainKey() -> String {
        
        guard let ai = ai else {
            return ""
        }
        
        var keysToChoose = [String]()
        
        for ship in ai.shipKeysPlayer ?? [] {
            
            for key in ship.1 {
                //Search for latest attacked ship of the player
                if key == lastAttackKey {
                    keysToChoose = ship.1
                }
            }
        }
        
        for key in keysToChoose {
            
            //If there are more keys of this ship available -> ship is not totally destroyed yet
            if key != lastAttackKey && ai.shipKeysPlayerString?.contains(key) ?? false {
                return key
            }
        }
        
        return getHitKey()
    }
    
    /** Selects a key from the available keys that won't lead to a hit */
    fileprivate func getNoHitKey() -> String {
        
        //Last attack was a hit, so the 'no hit' should be somewhere around
        if lastAttackWasHit {
            guard let indexOfHit = ai?.allKeys?.index(of: lastAttackKey), let ai = ai else {
                return ""
            }
            
            for i in 1..<99 {
                
                //TODO: müsste auch in die andere richtung gehen
                let newIndex = indexOfHit % 99 + i
                
                //z.B letzter Index war 93 (zufällig letzter Eintrag im array) -> erster Durchlauf newIndex = 94 -> Index out of range exception
                if newIndex >= ai.allKeys?.count ?? 0 {
                    continue
                }
                
                guard let keyToAttack = ai.allKeys?[newIndex], let shipKeysPlayerString = ai.shipKeysPlayerString else {
                    return ""
                }
                
                if !shipKeysPlayerString.contains(keyToAttack) && generateNoHitKeysPlayer().contains(keyToAttack) {
                    return keyToAttack
                }
            }
        }
        //Last attack was no hit too, so it is not that important where the ai will attack (no hit) next
        
        let noHitKeys = generateNoHitKeysPlayer()
        let randomIndex = generateRandomAttackKey(value: noHitKeys.count)
        return noHitKeys[randomIndex]
    }
    
    fileprivate func generateNoHitKeysPlayer() -> [String] {
        
        let allKeysSet = Set(ai?.allKeys ?? [])
        let hitKeysSet = Set(ai?.shipKeysPlayerString ?? [])
        //All keys that won't lead to hits
        let noHitKeysSet = allKeysSet.subtracting(hitKeysSet)
        
        return Array(noHitKeysSet)
    }
    
    /** Chooses a random index for a no hit key */
    fileprivate func generateRandomAttackKey(value: Int) -> Int {
        return Int(arc4random_uniform(UInt32(value)))
    }
    
    /** Returns a random number between 1 and 100 */
    fileprivate func generatePercentageToAttack() -> Int {
        return Int(arc4random_uniform(UInt32(100))) + 1
    }
}
