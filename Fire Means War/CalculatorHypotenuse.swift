//
//  CalculatorHypotenuse.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Calculates the hypotenuse between each cell and the touched ship */
class CalculatorHypotenuse: NSObject {
    
    /** Returns the calculated hypotenus between a ship and a cell */
    func getHypotenuse(ship: Ship, cell: Cell) -> CGFloat {
        return calculateHypotenuse(ship: ship, cell: cell)
    }

    fileprivate func calculateHypotenuse(ship: Ship, cell: Cell) -> CGFloat {
        
        //Absolute size of the cell
        let xCell = cell.absolutePositon["x"]!
        let yCell = cell.absolutePositon["y"]!
        
        //Pythagorean theorem
        let a = pow(Double(ship.getOriginX() - xCell), 2)
        let b = pow(Double(ship.getOriginY() - yCell), 2)
        let hypotenuse = sqrt(a + b)
        
        return CGFloat(hypotenuse)
    }

}
