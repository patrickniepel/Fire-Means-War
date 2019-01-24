//
//  MPCBrowser.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Handles the screen for choosing a peer */
class MPCBrowser: NSObject {
    
    var mBrowser : MCBrowserViewController?
    var delegate : MPCBrowserDelegate?
    var currentSession : MCSession?
    
    /** Initializes the browser */
    func setupBrowser(session: MCSession) {
        
        currentSession = session
        
        guard let currentSession = currentSession else {
            return
        }
        
        mBrowser = MCBrowserViewController(serviceType: "FireMeansWar", session: currentSession)
        delegate = MPCBrowserDelegate()
        mBrowser?.delegate = delegate
    }
    
    func stopBrowsingForPeers() {
        mBrowser?.browser?.stopBrowsingForPeers()
    }
}
