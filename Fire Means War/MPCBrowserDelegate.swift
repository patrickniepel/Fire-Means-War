//
//  MPCBrowserDelegate.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/** Delegate for the browser class */
class MPCBrowserDelegate: NSObject, MCBrowserViewControllerDelegate {
    
    // Done-Button was tapped
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    // Cancel-Button was tapped
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        //Cancel current session
        browserViewController.session.disconnect()
        browserViewController.dismiss(animated: true, completion: nil)
    }
}
