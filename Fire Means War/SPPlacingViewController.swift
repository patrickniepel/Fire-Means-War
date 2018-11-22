//
//  SPPlacingViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

enum PlacingState {
    case placing
    case waiting
    case delay
}

protocol SPPlacingSegueDelegate {
    //Message (concede / notPlaced / win / loss)
    func backFromSPPlacingScreen(ctrl: SPPlacingViewController, message: String)
}

class SPPlacingViewController: UIViewController, PopUpTimerDelegate, OptionsDelegate, SPAttackSegueDelegate, PauseSegueDelegate {
    
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
    
    var delegate : SPPlacingSegueDelegate? = nil
    
    var audioPlayer : AudioPlayer?
    
    var optionsScreen : PopUpOptionsViewController?
    var timerScreen : PopUpTimerViewController?
    
    var difficulty = 0
    var difficultyTitle = "Easy"
    
    var changedCells = [(String, Bool)]()
    
    var matchCtrl : SingleMatchController?
    var counterForAttack : Int = 0
    
    var userLeavesApplication = false
    
    var state : PlacingState = .placing
    
    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var fieldView: Field!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var shipsLeftLabel: UILabel!
    @IBOutlet weak var shipLeftIV: UIImageView!
    @IBOutlet weak var lifeIV: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.hidesBackButton = true
        
        backgroundImage.image = #imageLiteral(resourceName: "water3")
        
        shipCtrl = ShipController()
        shipPosCtrl = ShipPositionController()
        cellCtrl = CellController()
        
        if let shipPosCtrl = shipPosCtrl {
            cellCtrl?.setup(shipPos: shipPosCtrl)
        }
        
        navigationItem.title = difficultyTitle
        
        setupLabels()
        hideHUD()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleAttack), name: NSNotification.Name("aiAttacked"), object: nil)
        nc.addObserver(self, selector: #selector(handleShipsLeft), name: NSNotification.Name("shipsLeftOwn"), object: nil)
    }
    
    // When returning from attack screen
    override func viewWillAppear(_ animated: Bool) {
        
        // When back from Attack Screen
        if returned {
            state = .waiting
            infoLabel.text = "Opponent's Turn!"
            startWaitingTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !layoutCalledOnce {
            
            //If layout is needed again
            self.view.layoutIfNeeded()
            fieldView.layoutIfNeeded()

            layoutCalledOnce = true
            
            
            fieldCtrl = FieldController(view: view, field: fieldView)
            
            guard let shipPosCtrl = shipPosCtrl, let fieldCtrl = fieldCtrl, let shipCtrl = shipCtrl else {
                return
            }
            
            fieldCtrl.setup(shipPosCtrl: shipPosCtrl)
            
            fieldCtrl.populateField()
            shipCtrl.createShips(cellWidth: fieldCtrl.width, mainView: view, field: fieldView)
            cellCtrl?.shipCellsLeft = shipCtrl.cellsLeft
            
            lifeLabel.text = "\(shipCtrl.cellsLeft)"
            shipsLeftLabel.text = "\(shipCtrl.ships.count)"
            
            guard let snapCtrl = fieldCtrl.snapCtrl else {
                return
            }
    
            shipCtrl.setup(snapController: snapCtrl)
        }
        
        //Starts the 5sec timer before the match really starts
        if !returned {
            performSegue(withIdentifier: "spPlacingVC2popUpTimerVC", sender: nil)
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
        shipLeftIV.isHidden = true
        shipsLeftLabel.isHidden = true
        lifeIV.isHidden = true
        lifeLabel.isHidden = true
    }
    
    private func showHUD() {
        shipLeftIV.isHidden = false
        shipsLeftLabel.isHidden = false
        lifeIV.isHidden = false
        lifeLabel.isHidden = false
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
                    
                    guard let ship = touch.view as? Ship else {
                        return
                    }
                    
                    //Ships can be snapped to the position
                    fieldCtrl?.checkSnapPosition(touchedShip: ship)
                }
            }
        }
    }
    
    /** Delegate of the PopUpTimerViewController */
    func backFromPopUpView(ctrl: PopUpTimerViewController) {
        
        returned = true
        startPlacingTimer()
        
        audioPlayer?.playHorn()
        
        timerScreen = nil
        ctrl.dismiss(animated: true, completion: nil)
    }
    
    /** Starts to play the theme for a battle */
    private func startBattleMusic() {
        audioPlayer?.playBattle()
    }
    
    /** Delegate of the SPAttackViewController */
    func backFromSPAttackScreen(ctrl: SPAttackViewController, changedCellsFromAttack: [(String, Bool)]) {
        
        changedCells = changedCellsFromAttack
        ctrl.navigationController?.popViewController(animated: false)
    }
    
    /** Second Delegate method of the SPAttackViewController, back to the main menu */
    func backFromSPAttackScreen(ctrl: SPAttackViewController, message: String) {
        
        ctrl.navigationController?.popViewController(animated: false)
        delegate?.backFromSPPlacingScreen(ctrl: self, message: message)
    }
    
    /** Delegate of the OptionsViewController */
    func concedeFromOptionsView(ctrl: PopUpOptionsViewController) {
        ctrl.dismiss(animated: false, completion: nil)
        optionsScreen = nil
        
        // Returns to the menu
        delegate?.backFromSPPlacingScreen(ctrl: self, message: "concede")
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
        
        if placingCounter == 25 {
            startBattleMusic()
        }
        
        if placingCounter <= 5 {
            timerLabel.textColor = .red
        }
        
        //Player did place all ships, host starts his attack
        guard let checkShipsPlayer = shipCtrl?.checkIfShipsPlaced() else {
            return
        }
        
        if placingCounter == 0 && checkShipsPlayer{
            
            mTimer?.invalidate()
            
            //Match with AI will be created
            createMatch()
            
            //Ships cant be dragged after the placing time
            shipCtrl?.removeGestureRecognizer()
            self.view.isUserInteractionEnabled = false
            
            // Displays the attack screen
            performSegue(withIdentifier: "spPlacingVC2spAttackVC", sender: nil)
            
            showHUD()
        }
            
            // Player did not place all ships, match gets cancelled
        else if placingCounter == 0 {
            
            delegate?.backFromSPPlacingScreen(ctrl: self, message: "notPlaced")
        }
            
            // Timer ticks
        else {
            timerLabel.text = "\(placingCounter) s"
        }
    }
    
    /** Creates Match with AI */
    private func createMatch() {
        guard let playerShips = shipPosCtrl?.getcellShipKeys() else {
            return
        }
        matchCtrl = SingleMatchController(difficulty: difficultyTitle, playerShipKeys: playerShips)
        matchCtrl?.createMatch()
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
        
        //Generate random number for starting the ai attack
        counterForAttack = matchCtrl?.getCounterForAttack() ?? 0
    }
    
    /** Timer for waiting for opponent's attacks */
    private func resumeWaitingTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleWaitingTimer), userInfo: nil, repeats: true)
        
        //Generate random number for starting the ai attack
        counterForAttack = matchCtrl?.getCounterForAttack() ?? 0
    }
    
    @objc func handleWaitingTimer() {
        
        waitingCounter -= 1
        
        if counterForAttack == waitingCounter {
            //New turn -> first attack
            matchCtrl?.setFirstAttackInTurn(firstAttack: true)
            matchCtrl?.attackPlayer(wait: false)
        }
        
        if waitingCounter <= 5 {
            timerLabel.textColor = .red
        }
        
        if waitingCounter == 0 {
            mTimer?.invalidate()
            
            // Back to placing screen again
            performSegue(withIdentifier: "spPlacingVC2spAttackVC", sender: nil)
        }
        else {
            timerLabel.text = "\(waitingCounter) s"
        }
    }

    /** AI attacked a cell */
    @objc func handleAttack(notification: NSNotification) {
        
        // Get the key of the attacked cell
        guard let cellKey = ExtractMessage().extractKey(notification: notification, keyword: "aiAttacked") else {
            return
        }
        // Check if there is a ship upon the attacked cell
        let cell = fieldCtrl?.cellGotAttacked(key: cellKey)
        
        guard let isAttack = matchCtrl?.checkAIAttack(cellKey: cellKey) else {
            return
        }
        
        // Ship got attacked
        if isAttack {
            
            matchCtrl?.removeAttackedKeyFromAIPlayerKeysArray(key: cellKey)
            
            //Reduce lp
            //lifeLabel.text = "\(Int(lifeLabel.text!)! - 1)"
            lifeLabel.text = "\(matchCtrl?.getPlayerCellsLeft() ?? -1)"
            
            audioPlayer?.playFire()
            
            //Sets the correct appearance for the cell
            cell?.shipOnCellAttackedDefender()
            
            infoLabel.text = "Opponent Hit A Ship!"
            checkForMatchResult()
        }
            // No ship got attacked
        else {
            audioPlayer?.playMissed()
            
            //Sets the correct appearance for the cell
            cell?.noShipOnCellAttackedDefender()
            
            infoLabel.text = "Opponent Missed!"
            stopTimer()
            startDelay2Attack()
        }
    }
    
    /** Gets called when the ai attacks a ship cell of the player */
    @objc func handleShipsLeft(notification: NSNotification) {
        //shipsLeftLabel.text = "\(Int(shipsLeftLabel.text!)! - 1)"
        shipsLeftLabel.text = "\(matchCtrl?.getPlayerShipsLeft() ?? -1)"
    }
    
    private func startDelay2Attack() {
        state = .delay
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleDelay), userInfo: nil, repeats: true)
    }
    
    @objc func handleDelay() {
        
        delayCount -= 1
        
        if delayCount == 0 {
            delayCount = 3
            mTimer?.invalidate()
            performSegue(withIdentifier: "spPlacingVC2spAttackVC", sender: nil)
        }
    }
    
    /** Pauses the match and shows the pause screen */
    private func pauseMatch() {
        mTimer?.invalidate()
        audioPlayer?.pauseResumeBattlePlayer(pause: true)
        
        if state == .waiting {
            matchCtrl?.pauseResumeAI(pause: true)
        }
    }
    
    func backFromPauseScreen(ctrl: PauseViewController) {
        ctrl.dismiss(animated: true, completion: nil)
        audioPlayer?.pauseResumeBattlePlayer(pause: false)
        
        if state == .placing {
            startPlacingTimer()
        }
        if state == .waiting {
            resumeWaitingTimer()
            matchCtrl?.pauseResumeAI(pause: false)
        }
        if state == .delay {
            startDelay2Attack()
        }
    }
    
    /** Checks if player lost the match */
    private func checkForMatchResult() {
        
        guard let aiWin = matchCtrl?.checkForAIWin() else {
            return
        }
        
        if  aiWin {
            
            mTimer?.invalidate()
            
            //Fades out the battle theme
            audioPlayer?.volumeToZeroBattleTheme()
            audioPlayer?.playDefeat()
            showAlertSP(title: "Defeat", message: "You lose")
        }
        // AI attacks again, because player has not lost yet and the last attack hit a ship
        else {
            //AI wont attack again if only 3 seconds or less left
            matchCtrl?.setWaitingCounter(counter: waitingCounter)
            matchCtrl?.attackPlayer(wait: true)
        }
    }
    
    /** Alert function used for singleplayer mode, player wins */
    private func showAlertSP(title: String, message: String) {
        
        let alertSheetController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action -> Void in
            self.delegate?.backFromSPPlacingScreen(ctrl: self, message: "loss")
        }
        alertSheetController.addAction(continueAction)
        
        self.present(alertSheetController, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "spPlacingVC2popUpTimerVC" {
            
            let destVC = segue.destination as? PopUpTimerViewController
            timerScreen = destVC
            destVC?.delegate = self
        }
        
        if segue.identifier == "spPlacingVC2spAttackVC" {
            
            let destVC = segue.destination as? SPAttackViewController
            
            destVC?.delegate = self
            destVC?.matchCtrl = matchCtrl
            destVC?.changedCells = changedCells
            destVC?.audioPlayer = audioPlayer
            destVC?.difficultyTitle = difficultyTitle
        }
        
        if segue.identifier == "spPlacingVC2popUpOptionsVC" {
            
            let destVC = segue.destination as? PopUpOptionsViewController
            optionsScreen = destVC
            destVC?.delegate = self
        }
        
        if segue.identifier == "spPlacingVC2pauseVC" {
            
            let destVC = segue.destination as? PauseViewController
            destVC?.delegate = self
            pauseMatch()
        }
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("aiAttacked"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("shipsLeftOwn"), object: nil)
    }
}
