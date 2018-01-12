//
//  MPCSessionDelegate.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Delegate of the session class */
class MPCSessionDelegate: NSObject, MCSessionDelegate {
    
    var peerID : MCPeerID!
    
    /** Sends a notification when the state of a peer (opponent) changes */
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userInfo = ["peerID" : peerID, "state" : state.rawValue] as [String : Any]
        
        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: NSNotification.Name("MC_DidChangeState"), object: nil, userInfo: userInfo)
        })
    }
    
    /** Sends a notification when a peer received data from the opponent */
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let extractCtrl = ExtractMessage()
        let dataDict = extractCtrl.extract(data: data)
        let key = dataDict["key"]!
        
        let keyDict = ["key" : key]
        
        // Gets handled in PlacingViewController
        // Notification sent from AttackViewController
        if key == "attack" {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("didReceiveAttack"), object: nil, userInfo: dataDict)
            })
        }
            
        // Gets handled in AttackVieController
        // Notification sent from PlacingViewController
        else if key == "noHit" || key == "hit" {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("didAttack"), object: nil, userInfo: keyDict)
            })
        }
            
        // Gets handled in MPCHandler
        // Notification sent from MPCHandler
        else if key == "selfDisconnected" {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("selfDisconnected"), object: nil, userInfo: nil)
            })
        }
            
        // Gets handled in MPCHandler
        // Notification sent from MPCHandler (called in PlacingViewController)
        else if key == "host" {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("generatedHostNumber"), object: nil, userInfo: dataDict)
            })
        }
        
        //Handled in AttackVC
        else if key == "reduceShipsLeft" {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("reduceShipsLeft"), object: nil, userInfo: nil)
            })
        }
            
        // Gets handled in MainMenuViewController
        // Notifications sent from PlacingViewController and AttackViewController
        else {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: NSNotification.Name("MC_DidReceiveData"), object: nil, userInfo: keyDict)
            })
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL???, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }
}
