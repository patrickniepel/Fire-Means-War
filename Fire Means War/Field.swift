//
//  Field.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

/** Model for the game field */
class Field: UIView {
    
    // Number of rows and columns
    let cellsPerRow = 10
    
    //Key = 0|0 (position on the field)
    var cells = [String : Cell]()
    
    func getOriginX() -> CGFloat {
        return self.frame.origin.x
    }
    
    func getOriginY() -> CGFloat {
        return self.frame.origin.y
    }

}
