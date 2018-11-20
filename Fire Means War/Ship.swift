//
//  Ship.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Model of a ship */
class Ship: UIImageView {
    
    // Length from 2 to 4
    var mLength = 0
    var isPlaced = false
    var horizontal = false
    var startingPosition : CGPoint!
    
    var imageV : UIImage!
    var imageH : UIImage!
    
    //Keys of the cells on which the ship is placed
    var positionKeys = [String]()
    
    //Keys of the cells for a ship which must not overlap with other ships
    var overlappingKeys = [String]()
    
    init(frame: CGRect, length: Int) {
        super.init(frame: frame)
        self.frame = frame
        mLength = length
        
        loadShipLayout()
        
        // Player can touch and drag the ship
        self.isUserInteractionEnabled = true
        self.image = imageV
        self.contentMode = UIView.ContentMode.scaleAspectFill
        
        // Warning Color, only visible when borderWidth > 0
        // Warning gets set when ship is not placed correctly
        self.layer.borderColor = UIColor.red.cgColor
        setWarning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getOriginX() -> CGFloat {
        return self.frame.origin.x
    }
    
    func getOriginY() -> CGFloat {
        return self.frame.origin.y
    }
    
    // Switches height and width and changes the horizontal-value
    func rotate() {
        horizontal = !horizontal
        
        let width = self.frame.width
        let height = self.frame.height
        
        self.frame.size.width = height
        self.frame.size.height = width
        
        if horizontal {
            self.image = imageH
        }
        else {
            self.image = imageV
        }
    }
    
    func setWarning() {
        self.layer.borderWidth = 2
    }
    
    func unsetWarning() {
        self.layer.borderWidth = 0
    }
    
    fileprivate func loadShipLayout() {
        let shipLayoutNumber = UserDefaults.standard.integer(forKey: "shipLayout")
        
        if shipLayoutNumber == 0 {
            imageV = #imageLiteral(resourceName: "shipV")
            imageH = #imageLiteral(resourceName: "shipH")
        }
        if shipLayoutNumber == 1 {
            imageV = #imageLiteral(resourceName: "schiffVertikal")
            imageH = #imageLiteral(resourceName: "schiffHorizontal")
        }
    }
}
