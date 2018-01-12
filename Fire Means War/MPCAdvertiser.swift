//
//  MPCAdvertiser.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Handles the advertisement.
    Makes the peer "visible" to be able to get invitations from other players
 */
class MPCAdvertiser: NSObject, MCAdvertiserAssistantDelegate {
    
    var mAdvertiser : MCAdvertiserAssistant? = nil
    var session : MCSession!
    
    /** Starts or stops the advertisement */
    func advertiseSelf(advertise: Bool) {
        
        if advertise {
            mAdvertiser = MCAdvertiserAssistant(serviceType: "FireMeansWar", discoveryInfo: nil, session: session)
            mAdvertiser!.delegate = self
            mAdvertiser!.start()
        }
        else {
            mAdvertiser!.stop()
            mAdvertiser = nil
        }
    }
}
