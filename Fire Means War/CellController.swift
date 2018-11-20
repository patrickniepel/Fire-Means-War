//
//  CellController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 23.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Manages the cells of the game field */
class CellController: NSObject {
    
    //Cells that are left for getting attacked
    var shipCellsLeft = 0
    var shipPosCtrl : ShipPositionController!
    var mpcHandler : MPCHandler!
    lazy var shipPositionsTMP = [[String]]()
    
    func setup(shipPos: ShipPositionController) {
        shipPosCtrl = shipPos
    }
    
    func setupShipPositionsTMP(shipPos: [(Ship, [String])]) {
        fillShipPositionsTMP(shipPos: shipPos)
    }

    /** Checks if a ship lies on the given cell
        Returns true when a ship cell got attacked
     */
    func shipCellGotAttacked(cell: Cell, fieldView: Field) -> Bool {
        
        // Field positionof the cell (e.g "0|1")
        let x = cell.fieldPosition["x"]!
        let y = cell.fieldPosition["y"]!
        
        let xKey = String(describing: x)
        let yKey = String(describing: y)
        
        let cellKey = "\(xKey)|\(yKey)"
        
        // Checks if the cell with the specified key got attacked
        let gotAttacked = shipPosCtrl.checkForAttack(cellKey: cellKey)
        
        //let mpcHandler = MPCHandler.sharedInstance
        
        if gotAttacked {
            
            removeKeyFromTMPPositions(key: cellKey)
            
            shipCellGotAttacked()
            
            // Sets the occurence of the cell
            cell.shipOnCellAttackedDefender()
            
            fieldView.bringSubviewToFront(cell)
            
            // Sends a message to the opponent that the he attacked a cell on which one of the ships is placed
            mpcHandler.sendMessage(key: "hit", additionalData: "")
            
            return true
        }
        else {
            
            // Sets the occurence of the cell
            cell.noShipOnCellAttackedDefender()
            
            // Sends a message to the opponent that he missed the ship
            mpcHandler.sendMessage(key: "noHit", additionalData: "")
            return false
        }
    }
    
    // Decreases the number of available cells to hit, when 0 -> Match lost
    fileprivate func shipCellGotAttacked() {
        shipCellsLeft -= 1
    }
    
    /** Checks if player is about to lose */
    func checkForDefeat() -> Bool {
        
        if shipCellsLeft == 0 {
            
            // Match does not get terminated immediately (player can look at the match result for 2 seconds)
            sleep(2)
            return true
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
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name("shipsLeftOwn"), object: nil, userInfo: nil)
            mpcHandler.sendMessage(key: "reduceShipsLeft", additionalData: "")
        }
    }
    
    /** Fills the temporary array, works like a copy to be able to do changes */
    fileprivate func fillShipPositionsTMP(shipPos: [(Ship, [String])]) {
        
        for shipPositions in shipPos {
            shipPositionsTMP.append(shipPositions.1)
        }
    }
    
    /** Returns the position-key of the cell in the game field */
    func getKeyForCell(cell: Cell) -> String {
        
        let x = cell.fieldPosition["x"]!
        let y = cell.fieldPosition["y"]!
        
        let xKey = String(describing: x)
        let yKey = String(describing: y)
        
        return "\(xKey)|\(yKey)"
    }

}
