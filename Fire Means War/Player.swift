//
//  Player.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Model for a player */
class Player : NSObject {
    
    var name : String?
    var peerID : MCPeerID?
    var isHost = false
    
    //Number the gets generated for determining the host
    var hostNumber : Int?
    
    // var didPlaceAllShips = false
    
    func generateRandomNumber() {
        hostNumber = Int(arc4random_uniform(UInt32(1000)))
    }
}

