//
//  ExtractMessage.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 21.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity


/** Extracts the JSON data and dictionaries */
class ExtractMessage: NSObject {
    
    /** Extracts the JSON data (message from opponent) for the session delegate */
    func extract(data: Data) -> [String : String] {
        
        
        guard let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : String]
            else {
                return ["key" : "error"]
        }
        return dataDict ?? [:]
    }
    
    /** 
     Extracts the key from the specified dictionary
     keys: concede, winner, didNotPlace, hit, noHit, attack, aiAttacked
     */
    func extractKey(notification: NSNotification, keyword: String) -> String? {
        
        guard let dataDict = notification.userInfo as? Dictionary<String, Any> else {
            return nil
        }
        let key = dataDict[keyword] as? String
        
        return key ?? nil
    }
    
    /** Extracts the state of a peer for the handlePeerChangedState-Method in den MainMenuVC */
    func extractState(notification: NSNotification) -> Int? {
        
        guard let dataDict = notification.userInfo as? Dictionary<String, Any> else {
            return nil
        }
        let userInfo = NSDictionary(dictionary: dataDict)
        let state = userInfo["state"] as? Int
        
        return state ?? nil
    }
    
    /** Extracts the id of a peer for the handlePeerChangedState-Method in den MainMenuVC */
    func extractPeerID(notification: NSNotification) -> MCPeerID? {
        
        guard let dataDict = notification.userInfo as? Dictionary<String, Any> else {
            return nil
        }
        let userInfo = NSDictionary(dictionary: dataDict)
        let peer = userInfo["peerID"] as? MCPeerID
        
        return peer ?? nil
    }
    
    func extractShipPosOpponent(notification: NSNotification) -> [(Ship, [String])]? {
        
        guard let dataDict = notification.userInfo as? Dictionary<String, Any> else {
            return nil
        }
        
        let shipPosOpponent = dataDict["shipPosOpponent"] as? [(Ship, [String])]
        
        return shipPosOpponent ?? nil
    }

}
