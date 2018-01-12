//
//  AITest.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.01.18.
//  Copyright © 2018 Patrick Niepel. All rights reserved.
//

import UIKit

class AITest: NSObject {
    
    var shipKeys : [[String]]!
    var noShipKeys : [String]!
    
    var allKeys : [String]!
    
    var shipKeysPlayerString : [String]!
    var shipKeysPlayer : [(Ship, [String])]!
    
    var difficulty : String!
    
    var shipsLeft : Int = 0
    var cellsLeft : Int = 0

    var chanceToAttack : Int = 50
    var chanceToAttackAgain : Int = 50
}
