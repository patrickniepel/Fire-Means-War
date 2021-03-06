//
//  MPCSession.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//* Handles the session of the connected players */
class MPCSession: NSObject {
    
    var mPeerID : MCPeerID?
    var mSession : MCSession?
    
    var delegate : MPCSessionDelegate?
    
    /** Initialising peer */
    func setupPeerWithDisplayName(displayName: String) {
        mPeerID = MCPeerID(displayName: displayName)
    }
    
    /** Starts the session */
    func setupSession() {
        
        guard let peerID = mPeerID else {
            return
        }
        mSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        setupDelegate()
    }
    
    // Initializes the delegate of the session */
    private func setupDelegate() {
        delegate = MPCSessionDelegate()
        mSession?.delegate = delegate
        delegate?.peerID = mPeerID
    }
    
    /** Sends a message to the opponent with the given key and data */
    func sendMessage(key : String, additionalData : String) {
        
        let dataDict = ["key" : key, "additionalData" : additionalData]

        guard let messageData = try? JSONSerialization.data(withJSONObject: dataDict, options: [])
            else {
                return
        }
        
        // Opponent
        guard let peers = mSession?.connectedPeers else {
            return
        }

        guard ((try? mSession?.send(messageData, toPeers: peers, with: MCSessionSendDataMode.reliable)) != nil)
            else {
                return
        }
    }
    
    /** Returns the display name of the opponent */
    func getOpponentName() -> String {
        let name = mSession?.connectedPeers[0].displayName
        
        return name ?? "Default Name"
    }
    

}
