//
//  MPCHandler.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Handles the framework (singleton) */
class MPCHandler: NSObject {
    
    //static let sharedInstance = MPCHandler()
    
    var session : MPCSession!
    var advertiser : MPCAdvertiser!
    var browser : MPCBrowser!
    var player : Player!
    
    var mainVC : MainMenuViewController!
    
    //False when opponent lost connection
    //True when opponent disconnects intentionally
    var opponentSelfDisconnected = false
    
    /** Initializes every important component of the framework */
    func startSetup(vc: MainMenuViewController) {
        initialise(vc: vc)
        
        session.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        session.setupSession()
        
        advertiser.session = session.mSession
        advertiser.advertiseSelf(advertise: true)
        
        initialisePlayer()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleSelfDisconnected), name: NSNotification.Name("selfDisconnected"), object: nil)
        nc.addObserver(self, selector: #selector(handleHost), name: NSNotification.Name("generatedHostNumber"), object: nil)
    }
    
    /** Displays the Connecting-Screen */
    func startSearchingForPeer() {
        
        let mcSession = session.mSession
        
        if mcSession != nil {
            browser.setupBrowser(session: mcSession!)
            
            // Browser screen gets presented (for (de)activating navigation bar)
            mainVC.browserVCOpen = true
            mainVC.present(browser.mBrowser, animated: true, completion: nil)
        }
    }
    
    fileprivate func initialise(vc: MainMenuViewController) {
        mainVC = vc
        session = MPCSession()
        advertiser = MPCAdvertiser()
        browser = MPCBrowser()
    }
    

    fileprivate func initialisePlayer() {
        player = Player()
        player.name = UIDevice.current.name
        player.peerID = session.mPeerID
    }
    
    func sendMessage(key : String, additionalData : String) {
        session.sendMessage(key: key, additionalData: additionalData)
    }
    
    /** Will be called if player disconnects session intentionally */
    func disconnect() {
        
        // If still connected -> noone lost connection -> inform opponent that player did not lost connection, but disconnectd intentionally
        if session.mSession.connectedPeers.count == 1 {
            session.sendMessage(key: "selfDisconnected", additionalData: "")
        }
        
        // Opponent will disconnect session intentionally
        opponentSelfDisconnected = true
        session.mSession.disconnect()
        
        // Stops timer if player is in placing-screen
        NotificationCenter.default.post(name: NSNotification.Name("receivedAlert"), object: nil)
        
        // Match is over, advertise again to be found by other players
        advertiser.advertiseSelf(advertise: true)
    }
    
    // When opponent sends "selfDisconnected"-Message
    @objc func handleSelfDisconnected(notification: NSNotification) {
        opponentSelfDisconnected = true
    }
    
    // Handles the decision of setting the host
    @objc func handleHost(notification: NSNotification) {
        
        let opponentNumber = ExtractMessage().extractKey(notification: notification, keyword: "additionalData")
        
        let number = Int(opponentNumber)!
        
        if player.hostNumber > number {
            player.isHost = true
        }
            
        else if number > player.hostNumber {
            player.isHost = false
        }
            
        // If numbers are equal
        else {
            sendHostMessage()
        }
    }
    
    /** Sends the message with the generated number for deciding who will be the host */
    func sendHostMessage() {
        player.generateRandomNumber()
        let myNumber = String(describing: player.hostNumber!)
        session.sendMessage(key: "host", additionalData: myNumber)
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("selfDisconnected"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("generatedHostNumber"), object: nil)
    }
}
