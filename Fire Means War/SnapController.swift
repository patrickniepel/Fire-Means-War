//
//  SnapController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 07.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

//Manages the Snapping Behavior of the ships
class SnapController: NSObject {
    
    var snap : UISnapBehavior!
    var animator : UIDynamicAnimator!
    var calcSnap : CalculatorSnapPosition!
    var field : Field!
    var shipPosCtrl : ShipPositionController!
    
    func setup(view: UIView, fieldView: Field, shipPos: ShipPositionController) {
        animator = UIDynamicAnimator(referenceView: view)
        calcSnap = CalculatorSnapPosition()
        field = fieldView
        shipPosCtrl = shipPos
    }
    
    /** Sets the snap position */
    func handleSnapPosition(ship: Ship) {
        animator.removeAllBehaviors()
        
        //Ship not placed yet; set when ship gets moved by the player
        ship.isPlaced = false
        ship.setWarning()
        
        var snapPoint : CGPoint!
        let calcHypo = CalculatorHypotenuse()
        
        // When ship is in distance of this value, it will snap
        let distance = field.frame.width / CGFloat(field.cellsPerRow) / 2
        
        // If ship (e.g length = 2) is horizontal on field, it should not snap if it is positioned on the right margin
        let count = field.cellsPerRow - ship.mLength + 1
        
        var x = 0
        var y = 0
        
        if ship.horizontal {
            // Limited horizontal
            x = count
            
            // All vertical
            y = field.cellsPerRow
        }
        else {
            // All horizontal
            x = field.cellsPerRow
            
            // Limited vertical
            y = count
        }
        
        // Check if ship can be snapped to cell
        for j in 0..<y {
            
            for i in 0..<x {
                
                let key = "\(i)|\(j)"
                let cell = field.cells[key]!
                
                //Get current hypotenuse
                let hypo = calcHypo.getHypotenuse(ship: ship, cell: cell)
                
                if hypo <= distance {
                    
                    snapPoint = calcSnap.getSnapPoint(field: field, ship: ship, cell: cell)
                    setSnapPosition(point: snapPoint, ship: ship)
                    setShipPosition(ship: ship, snappingCell: cell)
                    
                    // Check if ship is overlapping with other cells
                    if isOverlapping(ship: ship) {
                        snapToStartingPosition(ship: ship)
                    }
                }
            }
        }
    }
    
    fileprivate func setSnapPosition(point: CGPoint, ship: Ship) {
        snap = UISnapBehavior(item: ship, snapTo: point)
        animator.addBehavior(snap)
        
        // Ship is successfully placed after snapping to a position
        ship.isPlaced = true
        ship.unsetWarning()
    }
    
    /** Delegates to ShipPositionController for setting the correct position of each ship */
    fileprivate func setShipPosition(ship: Ship, snappingCell: Cell) {
        shipPosCtrl.setShipPosition(ship: ship, snappingCell: snappingCell)
    }
    
    fileprivate func isOverlapping(ship: Ship) -> Bool {
        return shipPosCtrl.isOverlapping(currentShip: ship)
    }
    
    /** Snaps the ship to its starting position */
    func snapToStartingPosition(ship: Ship) {
        animator.removeAllBehaviors()
        
        // Starting positions means vertical positioning
        if ship.horizontal {
            ship.rotate()
        }
        
        //Clears all positions that got set
        shipPosCtrl.resetPositions(ship: ship)
        
        let point = calcSnap.getSnapPointStartingPosition(ship: ship)
        snap = UISnapBehavior(item: ship, snapTo: point)
        animator.addBehavior(snap)
        
        // Ship is not placed
        ship.setWarning()
        ship.isPlaced = false
    }

}
