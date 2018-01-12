//
//  MainMenuViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 03.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import MultipeerConnectivity
import UIKit
import StoreKit

//View-Controller for the Main Menu
class MainMenuViewController: UIViewController, PlacingDelegate, DifficultySegueDelegate {
    
    var mpcHandler : MPCHandler!
    var selfDidNotPlaceAllShips = false
    
    //Required to set the navigation bar
    var browserVCOpen = false
    
    var alertCtrl : AlertController!
    var alert : UIAlertController!
    
    var audioPlayer = AudioPlayer()
    
    //True when there are alerts that have to be shown
    var alertToShow = false
    
    //True when match is running
    var isPlaying = false

    @IBOutlet weak var btnHostMatch: UIButton!
    @IBOutlet weak var btnTutorial: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    var buttons : [UIButton] = [UIButton]()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons = [btnPlay, btnHostMatch, btnTutorial, btnSettings, btnAbout]
        
        setupButtons()
        
        backgroundImage.image = #imageLiteral(resourceName: "testMain")
        
        //Initialises the Framework
        mpcHandler = MPCHandler()
        mpcHandler.startSetup(vc: self)
        
        alertCtrl = AlertController()
        
        //Starts playing the main theme
        audioPlayer.playMain()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handlePeerChangedState), name: NSNotification.Name("MC_DidChangeState"), object: nil)
        nc.addObserver(self, selector: #selector(handleReceivedData), name: NSNotification.Name("MC_DidReceiveData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setupNavigationBarTranslucent()
        browserVCOpen = false
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        infoReviewApplication()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !browserVCOpen {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if browserVCOpen {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    fileprivate func setupButtons() {
        
        for button in buttons {
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2
        }
    }
    
    fileprivate func infoReviewApplication() {
        
        let wasShown = UserDefaults.standard.bool(forKey: "info")
        
        if wasShown {
            return
        }
        
        let infoAlert = UIAlertController(title: "Welcome to the new version!", message:
            "\nFire Means War now contains a singleplayer mode! It would be great to get some feedback on how the singleplayer mode works to further improve the application (Note that this is an early version)\n\nContact me via email (You’ll find the address in the 'About' section) or click below to directly write a review!", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { action -> Void in
            UserDefaults.standard.set(true, forKey: "info")
        }
        let reviewAction = UIAlertAction(title: "Review", style: .default) { action -> Void in
            UserDefaults.standard.set(true, forKey: "info")
            
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
        infoAlert.addAction(closeAction)
        infoAlert.addAction(reviewAction)
        
        present(infoAlert, animated: true)
    }
    
    /** Delegate of PlacingViewController */
    func backFromPlacingScreen(alertToShow: Bool) {
        navigationController?.popToRootViewController(animated: false)
        
        if alertToShow {
            alert = alertCtrl.showAlert(title: "Defeat", message: "You concede")
            present(alert, animated: false)
        }
    }
    
    /** Second Delegate of PlacingViewController. Gets called when player lost the match */
    func backFromPlacingScreenLosing() {
        navigationController?.popToRootViewController(animated: false)
        let alert = alertCtrl.showAlert(title: "Defeat", message: "You lose")
        self.present(alert, animated: true) {}
    }
    
    /** Delegate of DifficultyViewController, contains message for alert */
    func backFromDifficultyScreen(ctrl: DifficultyViewController, message: String) {
         ctrl.navigationController?.popViewController(animated: false)
        
        audioPlayer.playMain()
        
        if message == "concede" {
            alert = alertCtrl.showAlert(title: "Defeat", message: "You concede")
            self.present(alert, animated: true)
        }
        if message == "notPlaced" {
            alert = alertCtrl.showAlert(title: "Match canceled", message: "You Did Not Place Every Single Ship")
            self.present(alert, animated: true)
        }
    }
    
    /** Host Match Button */
    @IBAction func hostGame(_ sender: UIButton) {
        mpcHandler.startSearchingForPeer()
    }
    
    /** When Player did not place all of his ships */
    func didNotPlaceAllShips() {
        selfDidNotPlaceAllShips = true
    }
    
    /** Gets called when the opponent's connection state changes */
    @objc func handlePeerChangedState(notification: NSNotification) {
        
        let state = ExtractMessage().extractState(notification: notification)
        let peer = ExtractMessage().extractPeerID(notification: notification)
        
        switch(state) {
            
        case MCSessionState.connecting.rawValue:
            print("Connecting")
            
            // When connecting with a peer, other peers that want to connect get kicked out
            if mpcHandler.session.mSession.connectedPeers.count == 1 {
                mpcHandler.session.mSession.cancelConnectPeer(peer)
            }
        
            
        case MCSessionState.connected.rawValue:
            print(state)
            print("Connected")
            
            // Stop main theme
            audioPlayer.volumeToZero()
            perform(#selector(stopPlayer), with: nil, afterDelay: 2)
            
            // When screen for choosing the opponent is on top
            if mpcHandler.browser.mBrowser != nil {
                mpcHandler.browser.stopBrowsingForPeers()
                mpcHandler.browser.mBrowser.dismiss(animated: false, completion: nil)
            }
            
            // Stops advertising cause match is currently running
            mpcHandler.advertiser.advertiseSelf(advertise: false)
            isPlaying = true
            
            // Display placing screen
            performSegue(withIdentifier: "mainMenuVC2placingVC", sender: nil)
            
            
        case MCSessionState.notConnected.rawValue:
            print("notConnected")
            
            if isPlaying {
                
                self.navigationController?.popToViewController(self, animated: false)
                
                // Connection lost. None of player did disconnect intentionally
                if !mpcHandler.opponentSelfDisconnected  {
                    alert = alertCtrl.showAlert(title: "Match canceled", message: "Connection Lost")
                    self.present(alert, animated: true)
                }
                
                // Player did not place all of his ships
                if selfDidNotPlaceAllShips {
                    alert = alertCtrl.showAlert(title: "Match canceled", message: "Not Every Single Ship Was Placed Correctly")
                    self.present(alert, animated: true)
                    selfDidNotPlaceAllShips = false
                }
                
                // There is another alert that has to be shown
                if alertToShow {
                    self.present(alert, animated: true) {}
                    alertToShow = false
                }
                
                // Disonnection means -> back in menu -> start music again
                audioPlayer.playMain()
            }
            
            isPlaying = false
            
            // Stop session
            mpcHandler.disconnect()
            
        default: print("Default called in handlePeerChangedMethod")
            
        }
    }
    
    /** Stops the main theme */
    @objc func stopPlayer() {
        audioPlayer.stop()
    }
    
    /** Player received some data from his opponent. Match is over */
    @objc func handleReceivedData(notification: NSNotification) {
        
        let key = ExtractMessage().extractKey(notification: notification, keyword: "key")
        
        switch(key) {
            
            case "winner":
                alert = alertCtrl.showAlert(title: "Victory", message: "You win")
            
            case "didNotPlace":

                alert = alertCtrl.showAlert(title: "Match canceled", message: "Not Every Single Ship Was Placed Correctly")
                selfDidNotPlaceAllShips = false
            
            case "concede":
                alert = alertCtrl.showAlert(title: "Victory", message: "Your opponent concedes")
            
            default: print("Default in handleReceivedData")
        }
        
        alertToShow = true
        
        // Session gets terminated because match is over
        mpcHandler.disconnect()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mainMenuVC2aboutVC" {
            
        }
        if segue.identifier == "mainMenuVC2placingVC" {
            
            let destVC = segue.destination as! PlacingViewController
            destVC.delegate = self
            destVC.mpcHandler = mpcHandler
            destVC.audioPlayer = audioPlayer
        }
        if segue.identifier == "mainMenuVC2settingsTVC" {
            
            let destVC = segue.destination as! SettingsTableViewController
            destVC.audioPlayer = audioPlayer
        }
        if segue.identifier == "mainMenuVC2difficultyVC" {
            
            let destVC = segue.destination as! DifficultyViewController
            
            destVC.delegate = self
            destVC.audioPlayer = audioPlayer
        }
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("MC_DidChangeState"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("MC_DidReceiveData"), object: nil)
    }
}
