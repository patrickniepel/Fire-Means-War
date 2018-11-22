//
//  CalculatorSnapPosition.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Calculates the postion to which the ship will be snapped */
class CalculatorSnapPosition: NSObject {
    
    /*
     * The snap point is always in the middle of the view
     * The calculate-funtions calculate the middle of the view with the given parameters and return it as CGPoint
    */
    
    /** Returns the calculated snap point if the ship is in horizontal position */
    func getSnapPointHorizontal(field: Field, ship: Ship, cell: Cell) -> CGPoint {
        return calculateHorizontal(field: field, ship: ship, cell: cell)
    }
    
    private func calculateHorizontal(field: Field, ship: Ship, cell: Cell) -> CGPoint {
        
        let width = cell.frame.width
        let x = field.getOriginX() + cell.getOriginX() + (ship.frame.width / 2)
        let y = field.getOriginY() + cell.getOriginY() + (width / 2)
        
        return CGPoint(x: x, y: y)
    }
    
    /** Returns the calculated snap point if the ship is in vertical position */
    func getSnapPointVertical(field: Field, ship: Ship, cell: Cell) -> CGPoint {
        return calculateVertical(field: field, ship: ship, cell: cell)
    }
    
    private func calculateVertical(field: Field, ship: Ship, cell: Cell) -> CGPoint {
        
        let width = cell.frame.width
        let x = field.getOriginX() + cell.getOriginX() + (width / 2)
        let y = field.getOriginY() + cell.getOriginY() + (ship.frame.height / 2)
        
        return CGPoint(x: x, y: y)
    }
    
    /** Calculates the snap point for snapping the ship to its starting position */
    func getSnapPointStartingPosition(ship: Ship) -> CGPoint {
        
        guard let xStart = ship.startingPosition?.x,
                let yStart = ship.startingPosition?.y else {
            return CGPoint(x: 0, y: 0)
        }
        
        let x = xStart + ship.frame.width / 2
        let y = yStart + ship.frame.height / 2
        
        return CGPoint(x: x, y: y)
    }
    
    func getSnapPoint(field: Field, ship: Ship, cell: Cell) -> CGPoint {
        if ship.horizontal {
            return calculateHorizontal(field: field, ship: ship, cell: cell)
        }
        return calculateVertical(field: field, ship: ship, cell: cell)
    }

}
