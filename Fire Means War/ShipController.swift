//
//  ShipController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 07.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Manages the ships */
class ShipController: NSObject {
    
    var ships = [Ship]()
    var numberOfShips = 8
    
    // Lenths of every single ship
    let lengths = [4, 3, 3, 3, 2, 2, 2, 2]
    
    // Cells that are left for being attacked
    // When 0 -> match lost
    var cellsLeft = 0
    
    var gesture : UITapGestureRecognizer!
    
    var snapCtrl : SnapController!
    
    func setup(snapController: SnapController) {
        snapCtrl = snapController
    }
    
    /** Creates the ships with its attributes */
    func createShips(cellWidth: CGFloat, mainView: UIView, field: Field) {
        
        let startX = field.getOriginX()
        
        // Ships will be placed 8 points below the game field
        let startY = field.getOriginY() + field.frame.height + 8
        
        for i in 0..<numberOfShips {
            
            // 2 taps for rotating
            gesture = UITapGestureRecognizer(target: self, action: #selector(handleRotation))
            gesture.numberOfTapsRequired = 2
            
            // Starting position of x and y
            let x = startX + (cellWidth * 1.3) * CGFloat(i)
            let y = startY
            
            // Initialising frame
            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellWidth * CGFloat(lengths[i]))
            
            // Creating shpi with its frame and length
            let ship = Ship(frame: frame, length: lengths[i])
            ship.startingPosition = CGPoint(x: x, y: y)
            
            ship.addGestureRecognizer(gesture)
            ships.append(ship)
            
            // Numbers of all cells that can be attacked
            // Equal to the ships length (1 length == 1 cell)
            cellsLeft += lengths[i]
        }
        addToView(view: mainView)
    }
    
    // Adds the ships as subviews to the main view
    fileprivate func addToView(view: UIView) {
        for ship in ships {
            view.addSubview(ship)
        }
    }
    
    func removeGestureRecognizer() {
        for ship in ships {
            ship.removeGestureRecognizer(gesture)
        }
    }
    
    // Gets the ships that is supposed to be rotated
    @objc func handleRotation(gesture: UITapGestureRecognizer) {
        let ship = gesture.view as! Ship
        ship.rotate()
        snapCtrl.handleSnapPosition(ship: ship)
    }
    
    /** If all ships are placed correctly -> matchs goes on
        If only one ship is not placed correctly -> match gets cancelled
    */
    func checkIfShipsPlaced() -> Bool {
        
        for ship in ships {
            if !ship.isPlaced {
                return false
            }
        }
        return true
    }
}
