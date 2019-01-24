//
//  ShipPositionController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 23.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

//Needs to be accessed from SnapController and CellController
class ShipPositionController: NSObject {
    
    // Each ship has array with PositionKeys
    private var cellShipKeys = [(Ship, [String])]()
    
    // Keys of cells that must no overlap with other cells
    private var cellOverlappingKeys = [(Ship, [String])]()
    
    func getcellShipKeys() -> [(Ship, [String])] {
        return cellShipKeys
    }
    
    /** Sets the correction position for a ship */
    func setShipPosition(ship: Ship, snappingCell: Cell) {
        
        let calcPos = CalculatorShipPosition()
        
        // Get the calculated cell keys
        let positionKeys = calcPos.getShipPosition(ship: ship, cell: snappingCell)
        ship.positionKeys = positionKeys
        
        // Now that the position is set, the overlapping cell keys can be calculated
        setOverlappingKeys(ship: ship, snappingCell: snappingCell)
        
        // If set is empty
        if cellShipKeys.count == 0 {
            cellShipKeys.append((ship, positionKeys))
            return
        }
        
        var containsShip = false
        
        // Ship is already in the set. Values get updated
        for i in 0..<cellShipKeys.count {
            
            if ship == cellShipKeys[i].0 {
                cellShipKeys[i].0 = ship
                cellShipKeys[i].1 = positionKeys
                containsShip = true
            }
        }
        
        // If ship is not already in the set
        if !containsShip {
            cellShipKeys.append((ship, positionKeys))
        }
    }
    
    
    /** Checks if the specified key is in the array of ShipCellKeys */
    func checkForAttack(cellKey: String) -> Bool {
        
        for i in 0..<cellShipKeys.count {
            
            let currentShip = cellShipKeys[i].0
            
            if currentShip.positionKeys.contains(cellKey) {
                return true
            }
        }
        
        return false
    }
    
    // Sets the keys of the cells that must not overlap with other cells
    private func setOverlappingKeys(ship: Ship, snappingCell: Cell) {
        
        let calcOverlap = CalculatorOverlapping()
        
        // Get the keys and set them
        let overlappingKeys = calcOverlap.getOverlappingKeys(ship: ship, cell: snappingCell)
        ship.overlappingKeys = overlappingKeys
        
        // If set is empty
        if cellOverlappingKeys.count == 0 {
            cellOverlappingKeys.append((ship, overlappingKeys))
            return
        }
        
        var containsShip = false
        
        // If ship is already in the set. Values get updated
        for i in 0..<cellOverlappingKeys.count {
            
            if ship == cellOverlappingKeys[i].0 {
                cellOverlappingKeys[i].0 = ship
                cellOverlappingKeys[i].1 = overlappingKeys
                containsShip = true
            }
        }
        
        // If ship is not already in the set
        if !containsShip {
            cellOverlappingKeys.append((ship, overlappingKeys))
        }
    }
    
    /** Checks if the ships is overlapping with other cells */
    func isOverlapping(currentShip: Ship) -> Bool {
        
        // Compares all ships that are already placed
        for i in 0..<cellOverlappingKeys.count {
            
            let placedShip = cellOverlappingKeys[i].0
            
            if placedShip == currentShip  {
                continue
            }

            let placedSet = Set(placedShip.overlappingKeys)
            let currentSet = Set(currentShip.positionKeys)
            
            // Checks if there are cells (keys) that overlap with each other
            if placedSet.intersection(currentSet).count > 0 {
                return true
            }
        }
        return false
    }
    
    /** Resets the position sets of the given ship */
    func resetPositions(ship: Ship) {
        ship.positionKeys = []
        ship.overlappingKeys = []
        
        var removeIndex = 0
        
        // Removes the ship from the set
        for i in 0..<cellShipKeys.count {
            
            if cellShipKeys[i].0 == ship {
                removeIndex = i
            }
        }
        cellShipKeys.remove(at: removeIndex)
        
        // Removes the ship from the set
        for i in 0..<cellOverlappingKeys.count {
            
            if cellOverlappingKeys[i].0 == ship {
                removeIndex = i
            }
        }
        cellOverlappingKeys.remove(at: removeIndex)
    }
}
