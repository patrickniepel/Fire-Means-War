//
//  PlacingViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol PlacingDelegate {
    
    /** Called when player lost the match */
    func backFromPlacingScreenLosing()
    
    func backFromPlacingScreen(alertToShow: Bool)
    
    /** Called when player did not place all of his ships */
    func didNotPlaceAllShips()
}

class PlacingViewController: UIViewController, PopUpTimerDelegate, AttackDelegate, OptionsDelegate {
    
    var fieldCtrl : FieldController?
    var shipCtrl : ShipController?
    var cellCtrl : CellController?
    var shipPosCtrl : ShipPositionController?
    
    // Timer for waiting for opponent's attacks
    // Timer between the end of an opponent's attack the the transition to the attack screen
    // Timer for placing the ships
    var mTimer : Timer?
    var waitingCounter = 20
    var placingCounter = 30
    var delayCount = 3
    
    // Layout already done
    var layoutCalledOnce = false
    
    //Back to placing screen
    var returned = false
    
    var mpcHandler : MPCHandler?
    
    //Cells that have changed after attack; Only for storing the data in between the transtions of the view controllers
    var changedCells = [(String, Bool)]()
    
    var delegate : PlacingDelegate? = nil
    
    var audioPlayer : AudioPlayer?
    
    var optionsScreen : PopUpOptionsViewController?
    var timerScreen : PopUpTimerViewController?
    
    var opponentShipsLeft = 0
    var opponentLifeLeft = 0

    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var fieldView: Field!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var shipsLeftLabel: UILabel!
    @IBOutlet weak var shipsLeftIV: UIImageView!
    @IBOutlet weak var lifeIV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        backgroundImage.image = #imageLiteral(resourceName: "water3")
        
        shipCtrl = ShipController()
        shipPosCtrl = ShipPositionController()
        cellCtrl = CellController()
        cellCtrl?.mpcHandler = mpcHandler
        
        if let shipPosCtrl = shipPosCtrl {
            cellCtrl?.setup(shipPos: shipPosCtrl)
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleAlert), name: NSNotification.Name("receivedAlert"), object: nil)
        nc.addObserver(self, selector: #selector(handleAttack), name: NSNotification.Name("didReceiveAttack"), object: nil)
        nc.addObserver(self, selector: #selector(handleShipsLeft), name: NSNotification.Name("shipsLeftOwn"), object: nil)
        
        //mpcHandler = MPCHandler.sharedInstance
        navigationItem.title = "vs \(mpcHandler?.session?.getOpponentName() ?? "Default Name")"
        
        //Sends a message to the opponent with the generated random number
        setHost()
        
        setupLabels()
        hideHUD()
    }
    
    // When returning from attack screen
    override func viewWillAppear(_ animated: Bool) {
        
        // When back from Attack Screen
        if returned {
            infoLabel.text = "Opponent's Turn!"
            startWaitingTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !layoutCalledOnce {
            
            //Set layout if needed again
            self.view.layoutIfNeeded()
            fieldView.layoutIfNeeded()
            
            layoutCalledOnce = true
            fieldCtrl = FieldController(view: view, field: fieldView)
            
            guard let shipPosCtrl = shipPosCtrl,
                let fieldCtrl = fieldCtrl,
                let cellCtrl = cellCtrl,
                let shipCtrl = shipCtrl else {
                return
            }
            fieldCtrl.setup(shipPosCtrl: shipPosCtrl)
            
            fieldCtrl.populateField()
            shipCtrl.createShips(cellWidth: fieldCtrl.width, mainView: view, field: fieldView)
            cellCtrl.shipCellsLeft = shipCtrl.cellsLeft
            
            lifeLabel.text = "\(shipCtrl.cellsLeft)"
            shipsLeftLabel.text = "\(shipCtrl.ships.count)"
            
            opponentShipsLeft = shipCtrl.ships.count
            opponentLifeLeft = shipCtrl.cellsLeft
            
            if let snapCtrl = fieldCtrl.snapCtrl {
                shipCtrl.setup(snapController: snapCtrl)
            }
        }
        
        //Starts the 5sec timer before the match really starts
        if !returned {
            performSegue(withIdentifier: "placingVC2popUpTimerVC", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // If the popups are currently displayed and this view controllers gets terminated
        optionsScreen?.dismiss(animated: false, completion: nil)
        timerScreen?.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    private func setupLabels() {
        timerLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        infoLabel.text = "Place Your Ships, Captain!"
        topIV.layer.borderWidth = 2
        topIV.layer.borderColor = UIColor.white.cgColor
    }
    
    private func hideHUD() {
        shipsLeftIV.isHidden = true
        shipsLeftLabel.isHidden = true
        lifeIV.isHidden = true
        lifeLabel.isHidden = true
    }
    
    private func showHUD() {
        shipsLeftIV.isHidden = false
        shipsLeftLabel.isHidden = false
        lifeIV.isHidden = false
        lifeLabel.isHidden = false
    }
    
    private func setHost() {
        mpcHandler?.sendHostMessage()
    }
    
    // Player drags the ships
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            for ship in shipCtrl?.ships ?? [] {
                
                if ship.frame.contains(touch.location(in: view)) {
                    
                    if let ship = touch.view as? Ship {
                        // Ship always in center of the touch
                        ship.center = touch.location(in: view)
                    }
                }
            }
        }
    }
    
    // Player stops dragging a ship
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            for ship in shipCtrl?.ships ?? [] {
                
                if ship.frame.contains(touch.location(in: view)) {
                    
                    if let ship = touch.view as? Ship {
                        //Ships can be snapped to the position
                        fieldCtrl?.checkSnapPosition(touchedShip: ship)
                    }
                }
            }
        }
    }
    
    /** Delegate of the PopUpTimerViewController */
    func backFromPopUpView(ctrl: PopUpTimerViewController) {
        
        returned = true
        startPlacingTimer()
        
        audioPlayer?.playHorn()
        perform(#selector(startBattleMusic), with: nil, afterDelay: 7)
        
        timerScreen = nil
        ctrl.dismiss(animated: true, completion: nil)
    }
    
    /** Starts to play the theme for a battle */
    @objc func startBattleMusic() {
        audioPlayer?.playBattle()
    }
    
    /** Delegate of the AttackViewController */
    func backFromAttackScreen(ctrl: AttackViewController, changedCellsFromAttack: [(String, Bool)], shipsLeftOpponent: Int, lifeLeftOpponent: Int) {
        
        // Caches the changed cells after the attack
        changedCells = changedCellsFromAttack
        opponentShipsLeft = shipsLeftOpponent
        opponentLifeLeft = lifeLeftOpponent
        ctrl.navigationController?.popViewController(animated: true)
    }
    
    /** Delegate of the OptionsViewController */
    func concedeFromOptionsView(ctrl: PopUpOptionsViewController) {
        ctrl.dismiss(animated: false, completion: nil)
        optionsScreen = nil
        
        // Player concedes so opponent will disconnect the session intentionally
        mpcHandler?.opponentSelfDisconnected = true
        
        // Send a message to the opponent that player will concede
        mpcHandler?.sendMessage(key: "concede", additionalData: "")
        
        // Returns to the menu
        backToMainScreen(alertToShow: true)
    }
    
    /** Delegate of the OptionsViewController */
    func continueFromOptionsView(ctrl: PopUpOptionsViewController) {
        optionsScreen = nil
        ctrl.dismiss(animated: true, completion: nil)
    }
    
    /** Timer for placing the ships */
    private func startPlacingTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handlePlacingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func handlePlacingTimer() {
        
        placingCounter -= 1
        
        if placingCounter <= 5 {
            timerLabel.textColor = .red
        }
        
        //Player did place all ships, host starts his attack
        if placingCounter == 0 && shipCtrl?.checkIfShipsPlaced() ?? false {
            
            mTimer?.invalidate()
            
            cellCtrl?.setupShipPositionsTMP(shipPos: shipPosCtrl?.getcellShipKeys() ?? [])
            
            //Ships cant be dragged after the placing time
            shipCtrl?.removeGestureRecognizer()
            self.view.isUserInteractionEnabled = false
            
            showHUD()
            
            // Displays the attack screen if the player is the host
            
            guard let playIsHost = mpcHandler?.player?.isHost else {
                return
            }
            if playIsHost {
                performSegue(withIdentifier: "placingVC2attackVC", sender: nil)
            }
            else {
                infoLabel.text = "Opponent's Turn!"
                startWaitingTimer()
            }
        }
        
        // Player did not place all ships, match gets cancelled
        else if placingCounter == 0 {
            mpcHandler?.opponentSelfDisconnected = true

            delegate?.didNotPlaceAllShips()
            
            // Sends a message to the opponent that player did not place all of his ships
            mpcHandler?.sendMessage(key: "didNotPlace", additionalData: "")
            backToMainScreen(alertToShow: false)
        }
            
        // Timer ticks
        else {
            timerLabel.text = "\(placingCounter) s"
        }
    }
    
    private func stopTimer() {
        mTimer?.invalidate()
    }
    
    /** Timer for waiting for opponent's attacks */
    private func startWaitingTimer() {
        waitingCounter = 20
        timerLabel.textColor = .white
        timerLabel.text = "\(waitingCounter)"
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleWaitingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func handleWaitingTimer() {
        
        waitingCounter -= 1

        if waitingCounter <= 5 {
            timerLabel.textColor = .red
        }
        
        if waitingCounter == 0 {
            mTimer?.invalidate()
            
            // Back to placing screen again
            performSegue(withIdentifier: "placingVC2attackVC", sender: nil)
        }
        else {
            timerLabel.text = "\(waitingCounter) s"
        }
    }
    
    /** Match got cancelled and this view controller is still presented */
    @objc func handleAlert(notification: NSNotification) {
        stopTimer()
        backToMainScreen(alertToShow: false)
    }
    
    /** Opponent attacked a cell */
    @objc func handleAttack(notification: NSNotification) {
        
        // Get the key of the attacked cell
        guard let cellKey = ExtractMessage().extractKey(notification: notification, keyword: "additionalData") else {
            return
        }
        
        // Check if there is a ship upon the attacked cell
        guard let cell = fieldCtrl?.cellGotAttacked(key: cellKey) else {
            return
        }
        
        guard let isAttack = cellCtrl?.shipCellGotAttacked(cell: cell, fieldView: fieldView) else {
            return
        }
        
        // Ship got attacked
        if isAttack {
            //Reduce lp
            lifeLabel.text = "\(Int(lifeLabel?.text ?? "") ?? 0 - 1)"
            
            audioPlayer?.playFire()
            infoLabel.text = "Opponent Hit A Ship!"
            checkForMatchResult()
        }
        // No ship got attacked
        else {
            audioPlayer?.playMissed()
            infoLabel.text = "Opponent Missed!"
            stopTimer()
            startDelay2Attack()
        }
    }
    
    /** Gets called when opponent hits a ship cell of the player */
    @objc func handleShipsLeft(notification: NSNotification) {
        shipsLeftLabel.text = "\(Int(shipsLeftLabel?.text ?? "") ?? 0 - 1)"
    }
    
    private func startDelay2Attack() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleDelay), userInfo: nil, repeats: true)
    }
    
    @objc func handleDelay() {
        
        delayCount -= 1
        
        if delayCount == 0 {
            delayCount = 3
            mTimer?.invalidate()
            performSegue(withIdentifier: "placingVC2attackVC", sender: nil)
        }
    }
    
    /** Checks if player lost the match */
    private func checkForMatchResult() {
        
        if cellCtrl?.checkForDefeat() ?? false {
            mpcHandler?.opponentSelfDisconnected = true
            
            // Player lost the game. Sends a message to the opponent that he won the match
            mpcHandler?.sendMessage(key: "winner", additionalData: "")
            
            delegate?.backFromPlacingScreenLosing()
        }
    }
    
    private func backToMainScreen(alertToShow: Bool) {
        delegate?.backFromPlacingScreen(alertToShow: alertToShow)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "placingVC2popUpTimerVC" {
            
            let destVC = segue.destination as? PopUpTimerViewController
            timerScreen = destVC
            destVC?.delegate = self
        }
        
        if segue.identifier == "placingVC2attackVC" {
            
            let destVC = segue.destination as? AttackViewController
            destVC?.delegate = self
            destVC?.mpcHandler = mpcHandler
            destVC?.audioPlayer = audioPlayer
            destVC?.changedCells = changedCells
            destVC?.shipCtrl = shipCtrl
            destVC?.shipsLeftOpponent = opponentShipsLeft
            destVC?.lifeLeftOpponent = opponentLifeLeft
        }
        
        if segue.identifier == "placingVC2popUpOptionsVC" {
            
            let destVC = segue.destination as? PopUpOptionsViewController
            optionsScreen = destVC
            destVC?.delegate = self
        }
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("receivedAlert"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("didReceiveAttack"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("shipsLeftOwn"), object: nil)
    }
}
