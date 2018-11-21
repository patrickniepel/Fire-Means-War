//
//  SPAttackViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

enum AttackState {
    case attack
    case delay
}

protocol SPAttackSegueDelegate {
    func backFromSPAttackScreen(ctrl: SPAttackViewController, changedCellsFromAttack: [(String, Bool)])
    func backFromSPAttackScreen(ctrl: SPAttackViewController, message: String)
}

class SPAttackViewController: UIViewController, OptionsDelegate, PauseSegueDelegate {
    
    // Timer for attacking a cell
    var mTimer : Timer?
    var attackCounter = 20
    
    var shipCtrl : ShipController?
    var fieldCtrl : FieldController?
    
    // Layout already done
    var layoutCalledOnce = false
    
    // Time between the end of an attack the the transition to the placing screen
    var delayCount = 3
    
    var gestureRecognizer : UITapGestureRecognizer?
    
    var audioPlayer : AudioPlayer?
    
    var optionsScreen : PopUpOptionsViewController?
    
    var difficultyTitle = "Easy"
    
    // Cells that have changed since the last attack (player does not need to remember which cells he already attacked)
    var changedCells = [(String, Bool)]()
    
    var delegate : SPAttackSegueDelegate? = nil
    
    var matchCtrl : SingleMatchController?
    
    var state : AttackState = .attack

    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var fieldView: Field!
    @IBOutlet weak var btnFire: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var shipsLeftLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        backgroundImage.image = #imageLiteral(resourceName: "water3")
        
        btnFire.layer.cornerRadius = 50
        
        shipCtrl = ShipController()
        
        // For selecting a cell as a target
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        if let gestureRecognizer = gestureRecognizer {
            fieldView.addGestureRecognizer(gestureRecognizer)
        }
        
        setupLabels()
        
        //Becomes visible when cell was selected
        btnFire.isHidden = true
        
        navigationItem.title = difficultyTitle
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleShipsLeft), name: NSNotification.Name("shipsLeftOpponent"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startTimer()
    }
    
    override func viewDidLayoutSubviews() {
        
        if !layoutCalledOnce {
            fieldCtrl = FieldController(view: view, field: fieldView)
            fieldCtrl?.populateField()
            fieldCtrl?.updateField(changedCells: changedCells)
            layoutCalledOnce = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // If optionsScreen is currently presenting when this viewController gets terminated
        optionsScreen?.dismiss(animated: false, completion: nil)
    }
    
    // Stops the attacking timer when viewController gets popped from the stack
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    fileprivate func setupLabels() {
        timerLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        infoLabel.text = "Choose A Target!"
        lifeLabel.text = "\(matchCtrl?.getAICellsLeft() ?? -1)"
        shipsLeftLabel.text = "\(matchCtrl?.getAIShipsLeft() ?? -1)"
        topIV.layer.borderWidth = 2
        topIV.layer.borderColor = UIColor.white.cgColor
    }
    
    /** Delegate of the OptionsViewController */
    func concedeFromOptionsView(ctrl: PopUpOptionsViewController) {
        ctrl.dismiss(animated: false, completion: nil)
        optionsScreen = nil
        
        delegate?.backFromSPAttackScreen(ctrl: self, message: "concede")
    }
    
    /** Delegate of the OptionsViewController */
    func continueFromOptionsView(ctrl: PopUpOptionsViewController) {
        optionsScreen = nil
        ctrl.dismiss(animated: true, completion: nil)
    }
    
    /** Timer for attacking */
    fileprivate func startTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopTimer() {
        mTimer?.invalidate()
    }
    
    @objc func handleTimer(timer: Timer) {
        
        attackCounter -= 1
        
        if attackCounter <= 5 {
            timerLabel.textColor = .red
        }
        if attackCounter == 0 {
            mTimer?.invalidate()
            delegate?.backFromSPAttackScreen(ctrl: self, changedCellsFromAttack: changedCells)
        }
        else {
            timerLabel.text = "\(attackCounter) s"
        }
    }
    
    /** Handles the tap gesture of the player -> selecting a cell */
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: fieldView)
        
        //Sometimes there will be a negative value for the location (Bug?)
        if location.x < 0 || location.y < 0 {
            return
        }
        fieldCtrl?.manageTargetGesture(location: location, changedCells: changedCells)
        
        //If there is a correct cell that was selected (e.g. not correct, if player selects a cell that was already attacked)
        if fieldCtrl?.selectedCell != nil {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                // Fire button gets active and player can interact
                self.btnFire.isHidden = false
            }, completion: nil)
        }
    }
    
    @IBAction func firePressed(_ sender: UIButton) {
        
        // If there is currently no other cell selected
        if fieldCtrl?.selectedCell == nil {
            infoLabel.textColor = .red
            infoLabel.text = "Choose A Target!"
        }
        else {
            // Fire was pressed an interaction gets disabled until the message of the opponent arrives (if a ship was attacked the interaction gets enabled again)
            if let gestureRecognizer = gestureRecognizer {
                fieldView?.removeGestureRecognizer(gestureRecognizer)
            }
            
            sender.isEnabled = false
            
            // Gets the key for the attacked cell
            guard let selectedCell = fieldCtrl?.selectedCell else {
                return
            }
            let key = CellController().getKeyForCell(cell: selectedCell)
            attackAI(cellKey: key)
        }
    }
    
    fileprivate func attackAI(cellKey: String) {
        
        guard let successfullAttack = matchCtrl?.checkPlayerAttack(cellKey: cellKey) else {
            return
        }
        
        infoLabel.textColor = .white
        
        if successfullAttack {
            
            //lifeLabel.text = "\(Int(lifeLabel.text!)! - 1)"
            lifeLabel.text = "\(matchCtrl?.getAICellsLeft() ?? -1)"
            
            // Plays sound for a successfully attacked cell
            audioPlayer?.playFire()
            
            // Sets the correct occurence for the attacked cell
            fieldCtrl?.selectedCell?.shipOnCellAttackedOffender()
            
            // Appends the cell to the set. Set will be assigned to a variable in the SPPlacingViewController to cache the progress
            changedCells.append((cellKey, true))
            
            infoLabel.text = "Nice! Do That Again!"
            
            // Player can choose another cell
            if let gestureRecognizer = gestureRecognizer {
                fieldView?.addGestureRecognizer(gestureRecognizer)
            }
            
            fieldCtrl?.updateField(changedCells: changedCells)
            btnFire.isEnabled = true
            
            // Resets selected cell
            fieldCtrl?.selectedCell = nil
            
            //After player attacks it will be checked if he wins
            guard let playerWin = matchCtrl?.checkForPlayerWin() else {
                return
            }
            
            if playerWin {
                
                mTimer?.invalidate()
                
                //Fades out the battle theme
                audioPlayer?.volumeToZeroBattleTheme()
                audioPlayer?.playVictory()
                showAlertSP(title: "Victory", message: "You Win")
            }
        }
        else {
            
            // Plays the sound that a ship was missed
            audioPlayer?.playMissed()
            
            stopTimer()
            
            // Sets the correct occurence for the attacked cell
            fieldCtrl?.selectedCell?.noShipOnCellAttackedOffender()
            
            // Appends the cell to the set. Set will be assigned to a variable in the placingViewController to cache the progress
            changedCells.append((cellKey, false))
            infoLabel.text = "You Missed!"
            
            // Start transition back to placing screen
            startDelay2Place()
        }
    }
    
    /** Gets called when the player attacks a ship cell of the ai */
    @objc func handleShipsLeft(notification: NSNotification) {
        //shipsLeftLabel.text = "\(Int(shipsLeftLabel.text!)! - 1)"
        shipsLeftLabel.text = "\(matchCtrl?.getAIShipsLeft() ?? -1)"
    }
    
    fileprivate func startDelay2Place() {
        state = .delay
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleDelay), userInfo: nil, repeats: true)
    }
    
    /** Time between the end of the attack phase and the transition back to the placing screen */
    @objc func handleDelay() {
        
        delayCount -= 1
        
        if delayCount == 0 {
            mTimer?.invalidate()

            delegate?.backFromSPAttackScreen(ctrl: self, changedCellsFromAttack: changedCells)
        }
    }
    
    /** Pauses the match and shows the pause screen */
    fileprivate func pauseMatch() {
        mTimer?.invalidate()
        audioPlayer?.pauseResumeBattlePlayer(pause: true)
    }
    
    func backFromPauseScreen(ctrl: PauseViewController) {
        ctrl.dismiss(animated: true, completion: nil)
        audioPlayer?.pauseResumeBattlePlayer(pause: false)
        
        if state == .attack {
            startTimer()
        }
        if state == .delay {
            startDelay2Place()
        }
    }
    
    /** Alert function used for singleplayer mode, player wins */
    fileprivate func showAlertSP(title: String, message: String) {
        
        let alertSheetController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action -> Void in
            self.delegate?.backFromSPAttackScreen(ctrl: self, message: "win")
        }
        alertSheetController.addAction(continueAction)
        
        self.present(alertSheetController, animated: true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "spAttackVC2popUpOptionsVC" {
            
            let destVC = segue.destination as? PopUpOptionsViewController
            optionsScreen = destVC
            destVC?.delegate = self
        }
        
        if segue.identifier == "spAttackVC2pauseVC" {
            
            let destVC = segue.destination as? PauseViewController
            destVC?.delegate = self
            pauseMatch()
        }
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("shipsLeftOpponent"), object: nil)
    }
}

