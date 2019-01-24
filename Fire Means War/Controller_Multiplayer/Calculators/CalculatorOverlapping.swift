//
//  CalculatorOverlapping.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.06.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Calculates the positions refering a ship that must not overlap with other positions */
class CalculatorOverlapping: NSObject {
    
    /** Returns the positions of the given ship for horizontal or vertical position that must not overlap */
    func getOverlappingKeys(ship: Ship, cell: Cell) -> [String] {
        
        if ship.horizontal {
            return horizontalPositions(shipLength: ship.mLength, cell: cell) ?? []
        }
        return verticalPositions(shipLength: ship.mLength, cell: cell) ?? []
    }
    
    /*
     * The functions below calculate all the keys of the cells on which the ship is placed and the keys of the cells around the ship
     * Between each ship has to be a space of 1 cell
     */
    
    private func horizontalPositions(shipLength: Int, cell: Cell) -> [String]? {
        
        // Position of the cell in the field (e.g "0|2")
        guard let xCell = cell.fieldPosition["x"], let yCell = cell.fieldPosition["y"] else {
            return nil
        }
        
        var overlappingKeys = [String]()
        
        // The first cell key that gets calculated lies 1 cell to the left of the origin of the ship -> loop begins with -1
        // 3 rows in the direction of y
        // Length of the ship + 2 rows in the direction of x
        for y in -1..<2 {
            
            for x in -1..<shipLength + 1 {
                
                let xKey = xCell + x
                let yKey = yCell + y
                let key = "\(xKey)|\(yKey)"
                
                overlappingKeys.append(key)
            }
        }
        
        return overlappingKeys
    }
    
    private func verticalPositions(shipLength: Int, cell: Cell) -> [String]? {
        
        guard let xCell = cell.fieldPosition["x"], let yCell = cell.fieldPosition["y"] else {
            return nil
        }
        
        var overlappingKeys = [String]()
        
        // Other side around to the loops of the function above
        // Length of the ship + 2 rows in the direction of y
        // 3 rows in the direction of x
        for y in -1..<shipLength + 1 {
            
            for x in -1..<2 {
                
                let xKey = xCell + x
                let yKey = yCell + y
                let key = "\(xKey)|\(yKey)"
                
                overlappingKeys.append(key)
            }
        }
        
        return overlappingKeys
    }

}
