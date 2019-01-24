//
//  Cell.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Model for a cell of the game field */
class Cell: UIImageView {
    
    // "x": 127
    var absolutePositon = [String : CGFloat]()
    
    // "x" : 1, "y" : 2
    var fieldPosition = [String: Int]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getOriginX() -> CGFloat {
        return self.frame.origin.x
    }
    
    func getOriginY() -> CGFloat {
        return self.frame.origin.y
    }
    
    /** Position of the cell in the main view */
    func setAbsolutePosition(fieldViewX: CGFloat, fieldViewY: CGFloat) {
        
        self.absolutePositon["x"] = self.getOriginX() + fieldViewX
        self.absolutePositon["y"] = self.getOriginY() + fieldViewY
    }
    
    /** State of the cell at the beginning */
    func setupForStart() {
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    /** One of the player's cells (on which a ship was placed) got attacked -> "fire" image -> increasing scale of the cell */
    func shipOnCellAttackedDefender() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(2.0, 2.0, 2.0)
            self.layer.borderWidth = 0
            self.image = UIImage(named: "fire")
        }, completion: nil)
    }
    
    /** One of the player's cell (no ship) got attacked -> "missed" image */
    func noShipOnCellAttackedDefender() {
        self.layer.borderWidth = 1
        self.image = UIImage(named: "Missed")
    }
    
    /** Player attacked a cell (on which a ship was placed) -> cell to normal scale -> "fire" image */
    func shipOnCellAttackedOffender() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DIdentity
        }, completion: nil)
        
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.image = UIImage(named: "fire")
    }
    
    /** Player attacked a cell (no ship) -> cell to normal scale -> "missed" image */
    func noShipOnCellAttackedOffender() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DIdentity
        }, completion: nil)
        
        self.layer.borderWidth = 1
        self.backgroundColor = .clear
        self.image = UIImage(named: "Missed")
    }
    
    /** Animates the cell to its default state */
    func animateToDefault() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DIdentity
            self.backgroundColor = .clear
            self.image = nil
        }, completion: nil)
    }
    
    /** Animates the cell to the state "chosen target".
        Gets called when the player chooses a cell while in attacking screen
     */
    func setupForAttack() {
        self.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        self.backgroundColor = .red
        self.image = UIImage(named: "target")
    }
    

}
