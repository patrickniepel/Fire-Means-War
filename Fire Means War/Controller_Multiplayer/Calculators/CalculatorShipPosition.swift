//
//  CalculatorShipPosition.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 23.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Calculates the position of the ship on the field */
class CalculatorShipPosition: NSObject {
    
    /** Returns the positions of the given ship for horizontal or vertical position */
    func getShipPosition(ship: Ship, cell: Cell) -> [String] {
        
        if ship.horizontal {
            return horizontalPosition(shipLength: ship.mLength, cell: cell) ?? []
        }
        return verticalPosition(shipLength: ship.mLength, cell: cell) ?? []
    }
    
    /*
     * The functions below calculate all the keys of the cells on which the ship is placed
    */
    
    private func horizontalPosition(shipLength: Int, cell: Cell) -> [String]? {
        
        // Position of the cell in the field (e.g "0|2")
        guard let xCell = cell.fieldPosition["x"], let yCell = cell.fieldPosition["y"] else {
            return nil
        }
        
        var shipPositions = [String]()
        
        // Each key from x to x + the lenght of the ship
        // y stays the same
        for i in xCell..<xCell + shipLength {
            
            let key = "\(i)|\(yCell)"
            shipPositions.append(key)
        }
        
        return shipPositions
    }
    
    // Similar to the function above
    private func verticalPosition(shipLength: Int, cell: Cell) -> [String]? {
        
        guard let xCell = cell.fieldPosition["x"], let yCell = cell.fieldPosition["y"] else {
            return nil
        }
        
        var shipPositions = [String]()
        
        // Each key from y to y + the length of the ship
        // x stays the same
        for i in yCell..<yCell + shipLength {
            
            let key = "\(xCell)|\(i)"
            shipPositions.append(key)
        }
        
        return shipPositions
    }
    

}
