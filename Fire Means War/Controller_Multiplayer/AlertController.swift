//
//  AlertController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 21.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit


/** Creates and returns a UIAlertController with the given title and message */
class AlertController: NSObject {
    
    /** Alert function used for multiplayer mode */
    func showAlert(title: String, message: String) -> UIAlertController {
        
        let alertSheetController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action -> Void in
        }
        alertSheetController.addAction(continueAction)
        
        return alertSheetController
    }
}
