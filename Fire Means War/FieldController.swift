//
//  FieldController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

//Controller for the game field
class FieldController: NSObject {
    
    var width : CGFloat = 0
    var snapCtrl : SnapController!
    
    // View in which the field is a subview of
    var topView : UIView!
    var fieldView : Field!
    
    //Cell that gets selected when in Attack Screen
    var selectedCell : Cell?
    
    init(view: UIView, field: Field) {
        topView = view
        fieldView = field
    }
    
    func setup(shipPosCtrl: ShipPositionController) {
        snapCtrl = SnapController()
        snapCtrl.setup(view: topView, fieldView: fieldView, shipPos: shipPosCtrl)
    }
    
    /** Fills the game field with cells */
    func populateField() {
        
        let cellsPerRow = fieldView.cellsPerRow
        width = fieldView.frame.size.width / CGFloat(cellsPerRow)
        
        for j in 0..<cellsPerRow {
            
            for i in 0..<cellsPerRow {
                
                let rect = CGRect(x: width * CGFloat(i), y: width * CGFloat(j), width: width, height: width)
                let cell = Cell(frame: rect)
                cell.setupForStart()
                
                fieldView.addSubview(cell)
                cell.fieldPosition["x"] = i
                cell.fieldPosition["y"] = j
                
                cell.setAbsolutePosition(fieldViewX: fieldView.getOriginX(), fieldViewY: fieldView.getOriginY())
                
                // Storing field position key
                let key = "\(i)|\(j)"
                fieldView.cells[key] = cell
            }
        }
    }
    
    /** Updates the field for the offender, so he sees which cells he has already attacked */
    func updateField(changedCells: [(String, Bool)]) {
    
        for i in 0..<changedCells.count {
            
            let key = changedCells[i].0

            //If true == successfully attacked -> fire image, else missed image
            if changedCells[i].1 {
                let cell = fieldView.cells[key]!
                cell.shipOnCellAttackedOffender()
            }
            else {
                let cell = fieldView.cells[key]!
                cell.noShipOnCellAttackedOffender()
            }
        }
    }
    
    /** Increases width and height when cell is selected (for choosing the target) */
    func manageTargetGesture(location: CGPoint, changedCells: [(String, Bool)]) {
        
        let cellsPerRow = fieldView.cellsPerRow
        let width = fieldView.frame.width / CGFloat(cellsPerRow)
        let i = Int(location.x / width)
        let j = Int(location.y / width)
        
        let key = "\(i)|\(j)"
        let cell = fieldView.cells[key]!
        
        // If selected Cell is a cell that got changed (already attacked) nothing happens and it cannot be attacked anymore
        for i in 0..<changedCells.count {
            let keyCellChanged = changedCells[i].0
            
            if key == keyCellChanged {
                return 
            }
        }
        
        //Lastly selected cell gets animated to default again
        if selectedCell != cell {
            
            selectedCell?.animateToDefault()
        }
        
        selectedCell = cell
        
        fieldView.bringSubview(toFront: cell)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            //Animate selected cell
            cell.setupForAttack()
        }, completion: nil)
    }
    
    /** Delegates the handling of the snap position to the SnapController */
    func checkSnapPosition(touchedShip: Ship) {
        snapCtrl.handleSnapPosition(ship: touchedShip)
    }
    
    /** Returns the cell that got attacked */
    func cellGotAttacked(key: String) -> Cell {
        let cell = fieldView.cells[key]
        return cell!
    }
}
