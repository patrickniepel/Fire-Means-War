//
//  AICalculator.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 15.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class AICalculator: NSObject {
    
    var availableKeys = [(Int, Int)]()
    var availableKeysString = [String]()
    
    /** Transforms the Integer set into a string set */
    private func changeDataTypeAvailableKeys() {
    
        for keyElement in availableKeys {
    
                let x = String(keyElement.0)
                let y = String(keyElement.1)
    
                let key = "\(x)|\(y)"
                availableKeysString.append(key)
        }
    }
    
    // -TODO: Bug vorhanden, manchmal befinden sich mehrere Schiffe (bis jetzt 2) auf der gleichen Stelle
    
    /** Loops through every ship that has to be created */
    func calculateShipPositions(allKeys: [(Int, Int)]) -> [[String]] {
        
        var positions = [[String]]()
        
        //Count, Length
        let shipCountLengths = [(1, 4), (3, 3), (4, 2)]
        
        //Array with used Keys, if once used cannot be used for other ships again
        availableKeys = allKeys
        changeDataTypeAvailableKeys()
        
        for shipElement in shipCountLengths {
            
            var ship = shipElement
            var keysAvailable = false
            var overlappingKeysAvailable = false
            
            while ship.0 > 0 {
                
                let randomKeyIndex = generateRandomKeyIndex(keysAvailable: availableKeysString.count)
                
                //Wenn schon benutzt muss anderer genommen werden
                let startingPosition = availableKeys[randomKeyIndex]
                let direction = generateRandomDirection()
                
                //Key values (Position)
                let x = startingPosition.0
                let y = startingPosition.1
                
                var area = [(Int, Int)]()
                
                //Starting Point of the ship
                let startingPoint = (x, y)
                area.append(startingPoint)
                
                switch direction {

                    //Define area for ship without overlapping
                case 0: // -y
                    //End Point y = starting y - (length of ship - 1)
                    let endPoint = (x, y - (ship.1 - 1))
                    area.append(endPoint)
                    
                case 1: // +x
                    //End Point y = starting y - (length of ship - 1)
                    let endPoint = (x + (ship.1 - 1), y)
                    area.append(endPoint)
                    
                case 2: // +y
                    //End Point y = starting y - (length of ship - 1)
                    let endPoint = (x, y + (ship.1 - 1))
                    area.append(endPoint)
                    
                case 3: // -x
                    //End Point y = starting y - (length of ship - 1)
                    let endPoint = (x - (ship.1 - 1), y)
                    area.append(endPoint)
                    
                default: // +y
                    //End Point y = starting y - (length of ship - 1)
                    let endPoint = (x, y + (ship.1 - 1))
                    area.append(endPoint)
                }
                
                let shipKeys = calculateShipKeys(area: area)
                keysAvailable = checkIfShipKeysAvailable(shipKeys: shipKeys)
                
                //If keys are not available, there is no need to proceed with the code below -> start next iteration
                if !keysAvailable {
                    continue
                }
                
                let overlappingKeys = calculateOverlappingKeys(area: area, shipKeys: shipKeys)
                overlappingKeysAvailable = checkIfOverlappingKeysAvailable(overlappingKeys: overlappingKeys, positions: positions)
                
                //If all calculated keys are available the next ship can be created
                if keysAvailable && overlappingKeysAvailable {
                    //One ship has been created, reduce ship counter
                    ship.0 -= 1
                    //Append the created keys to the array that holds all keys for every ship
                    positions.append(shipKeys)
                    //Remove the starting position keys from the array, so it cannot be used again
                    availableKeys.remove(at: randomKeyIndex)
                    //Remove all used keys from the stringArray, they are not available anymore
                    removeStringKeys(shipKeys: shipKeys, overlappingKeys: overlappingKeys)
                }
            }
        }
        
        return positions
    }
    
    /** Removes the used string keys from all keys */
    private func removeStringKeys(shipKeys: [String], overlappingKeys: [String]) {
        
        //Remove ship keys
        for i in 0..<shipKeys.count {
            
            if availableKeysString.contains(shipKeys[i]) {
                
                //Removes the used key for a ship from all keys -> cannot be used anymore
                availableKeysString.remove(at: i)
            }
        }
    }
    
    /** Calculates the area(cells) in which the ship is located */
    private func calculateShipKeys(area: [(Int, Int)]) -> [String] {
        
        var shipKeys = [String]()
        
        var xStart = area[0].0
        var yStart = area[0].1
        
        var xEnd = area[1].0
        var yEnd = area[1].1
        
        //If upperBound < lowerBound all start and end values will be switched to prevent loop from crashing
        if xStart > xEnd || yStart > yEnd {
            xStart = area[1].0
            xEnd = area[0].0
            
            yStart = area[1].1
            yEnd = area[0].1
        }
        
        //y direction
        for j in yStart...yEnd {
            //x direction
            for i in xStart...xEnd {
                
                let key = "\(i)|\(j)"
                shipKeys.append(key)
            }
        }
        
        return shipKeys
    }
    
    /** Calculates the overlapping keys for each ship */
    private func calculateOverlappingKeys(area: [(Int, Int)], shipKeys: [String]) -> [String] {
        
        var xStart = area[0].0
        var yStart = area[0].1
        
        var xEnd = area[1].0
        var yEnd = area[1].1
        
        //If upperBound < lowerBound all start and end values will be switched to prevent loop from crashing
        if xStart > xEnd || yStart > yEnd {
            xStart = area[1].0
            xEnd = area[0].0
            
            yStart = area[1].1
            yEnd = area[0].1
        }
        
        //Calculate overlapping keys
        let xStartOverlapping = xStart - 1
        let yStartOverlapping = yStart - 1
        
        let xEndOverlapping = xEnd + 1
        let yEndOverlapping = yEnd + 1
        
        var overlappingKeys = [String]()
        
        for j in yStartOverlapping...yEndOverlapping {
            
            for i in xStartOverlapping...xEndOverlapping {
                
                //If overlapping key is not within the field, there is no need to care for it, only the overlapping keys within the field are important (they have to be available too)
                if i < 0 || j < 0 || i > 9 || j > 9 {
                    continue
                }
                
                let overlappingKey = "\(i)|\(j)"
                
                //If calculated Key is actually no overlapping key but a ship key (because the whole are will be calculated) there is no need to care for it (the availability was already confirmed)
                if shipKeys.contains(overlappingKey) {
                    continue
                }
                
                overlappingKeys.append(overlappingKey)
            }
        }
        
        return overlappingKeys
    }
    
    /** Checks if the overlapping Keys are available for use */
    private func checkIfOverlappingKeysAvailable(overlappingKeys: [String], positions: [[String]]) -> Bool {
        
//        let allKeysSet = Set(availableKeysString)
//        let overlappingKeysSet = Set(overlappingKeys)
//
//        //If there are keys available a intersection exists
//        let intersection = allKeysSet.intersection(overlappingKeys)
//
//        //All shipKeys are available , keys in intersection are the same as in the overlappingKeysSet -> all overlapping keys are available for use
//        if intersection == overlappingKeysSet {
//            return true
//        }
        
        //Check overlapping keys with all ship keys that have already been calculated
        for ship in positions {
            
            for key in ship {
                //If overlapping key is equal to an already used ship key false will be returned
                if overlappingKeys.contains(key) {
                    return false
                }
            }
        }
        
        
        return true
    }
    
    /** Checks if the calculated keys for a ship are available for use */
    private func checkIfShipKeysAvailable(shipKeys: [String]) -> Bool {
        
        let allKeysSet = Set(availableKeysString)
        let shipKeysSet = Set(shipKeys)
        
        //If there are keys available a intersection exists
        let intersection = allKeysSet.intersection(shipKeysSet)
        
        //All shipKeys are available , keys in intersection are the same as in the shipKeySet -> all ship keys are available for use
        if intersection == shipKeysSet {
            return true
        }
        
        return false
    }
    
    private func generateRandomKeyIndex(keysAvailable: Int) -> Int {
        return Int(arc4random_uniform(UInt32(keysAvailable)))
    }
    
    func generateNewChanceValue(difficulty: String) -> (Int, Int) {
        
        var chanceFirst = 0
        var chanceAgain = 0
        
        if difficulty == "Easy" {//35, 40
            chanceFirst = Int(arc4random_uniform(UInt32(7))) + 32 // 32 - 38
            chanceAgain = Int(arc4random_uniform(UInt32(7))) + 37 // 37 - 43
        }
        if difficulty == "Medium" {//40, 45
            chanceFirst = Int(arc4random_uniform(UInt32(7))) + 37 // 37 - 43
            chanceAgain = Int(arc4random_uniform(UInt32(7))) + 42 // 42 - 48
        }
        if difficulty == "Hard" {//45, 50
            chanceFirst = Int(arc4random_uniform(UInt32(7))) + 42 // 42 - 48
            chanceAgain = Int(arc4random_uniform(UInt32(7))) + 47 // 47 - 53
        }
        
        return (chanceFirst, chanceAgain)
    }
    
    //0 up, 1 right, 2 down, 3 left
    private func generateRandomDirection() -> Int {
        return Int(arc4random_uniform(UInt32(4)))
    }
    
    /** Generates the counter for the first attack for each turn */
    func generateTimerCounterForAttack() -> Int {
        return Int(arc4random_uniform(UInt32(7))) + 10 //10 bis 16 Sekunden für das Angreifen
    }
    
    /** Generates a number between 1 and 3, time between attacks */
    func generateTimerCounterForAttackAgain() -> Int {
        return Int(arc4random_uniform(UInt32(3))) + 1 
    }
    
    
}
