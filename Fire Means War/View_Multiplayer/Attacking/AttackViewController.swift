//
//  AttackViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

protocol AttackDelegate {
    func backFromAttackScreen(ctrl: AttackViewController, changedCellsFromAttack: [(String, Bool)], shipsLeftOpponent: Int, lifeLeftOpponent: Int)
}

class AttackViewController: UIViewController, OptionsDelegate {
    
    var delegate : AttackDelegate? = nil
    
    var shipsLeftOpponent = 0
    var lifeLeftOpponent = 0
    
    // Timer for attacking a cell
    var mTimer : Timer?
    var attackCounter = 20
    
    var shipCtrl : ShipController?
    var fieldCtrl : FieldController?
    
    // Layout already done
    var layoutCalledOnce = false
    
    var mpcHandler : MPCHandler?
    
    // Time between the end of an attack the the transition to the placing screen
    var delayCount = 3
    
    var gestureRecognizer : UITapGestureRecognizer?
    
    // Cells that have changed since the last attack (player does not need to remember which cells he already attacked)
    var changedCells = [(String, Bool)]()
    
    var audioPlayer : AudioPlayer?
    
    var optionsScreen : PopUpOptionsViewController?

    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var fieldView: Field!
    @IBOutlet weak var btnFire: UIButton!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var shipsLeftLabel: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        backgroundImage.image = #imageLiteral(resourceName: "water3")
        
        btnFire.layer.cornerRadius = 50
        
        //mpcHandler = MPCHandler.sharedInstance
        navigationItem.title = "vs \(mpcHandler?.session?.getOpponentName() ?? "Default Name")"
        
        // For selecting a cell as a target
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        if let gestureRecognizer = gestureRecognizer {
            fieldView.addGestureRecognizer(gestureRecognizer)
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleAttack), name: NSNotification.Name("didAttack"), object: nil)
        nc.addObserver(self, selector: #selector(handleReduceShips), name: NSNotification.Name("reduceShipsLeft"), object: nil)
        
        setupLabels()
        
        //Becomes visible when cell was selected
        btnFire.isHidden = true
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

    private func setupLabels() {
        timerLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        infoLabel.text = "Choose A Target!"
        lifeLabel.text = "\(lifeLeftOpponent)"
        shipsLeftLabel.text = "\(shipsLeftOpponent)"
        topIV.layer.borderWidth = 2
        topIV.layer.borderColor = UIColor.white.cgColor
    }
    
    /** Delegate of the OptionsViewController */
    func concedeFromOptionsView(ctrl: PopUpOptionsViewController) {
        ctrl.dismiss(animated: false, completion: nil)
        optionsScreen = nil
        
        // When player concedes, his opponent will also disconnect the session intentionally
        mpcHandler?.opponentSelfDisconnected = true
        
        // Sends a message to the opponent that player concedes
        mpcHandler?.sendMessage(key: "concede", additionalData: "")
        
        // Back to menu
        navigationController?.popToRootViewController(animated: false)
    }
    
    /** Delegate of the OptionsViewController */
    func continueFromOptionsView(ctrl: PopUpOptionsViewController) {
        optionsScreen = nil
        ctrl.dismiss(animated: true, completion: nil)
    }
    
    /** Timer for attacking */
    private func startTimer() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        mTimer?.invalidate()
    }
    
    @objc func handleTimer(timer: Timer) {
        
        attackCounter -= 1
        
        if attackCounter <= 5 {
            timerLabel.textColor = .red
        }
        if attackCounter == 0 {
            mTimer?.invalidate()
            delegate?.backFromAttackScreen(ctrl: self, changedCellsFromAttack:  changedCells, shipsLeftOpponent: shipsLeftOpponent, lifeLeftOpponent: lifeLeftOpponent)
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
        guard let _ = fieldCtrl?.selectedCell else {
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            // Fire button gets active and player can interact
            self.btnFire.isHidden = false
        }, completion: nil)
    }
    
    /** Opponent sends a message if a ship was attacked or not */
    @objc func handleAttack(notification: NSNotification) {
        
        // Get the key "hit" or "noHit"
        let key = ExtractMessage().extractKey(notification: notification, keyword: "key")
        infoLabel.textColor = .white
        
        if key == "hit" {
            
            lifeLabel.text = "\(Int(lifeLabel?.text ?? "") ?? 0 - 1)"
            lifeLeftOpponent -= 1
            
            // Plays sound for a successfully attacked cell
            audioPlayer?.playFire()
            
            // Sets the correct occurence for the attacked cell
            fieldCtrl?.selectedCell?.shipOnCellAttackedOffender()
            
            // Gets the field position key of the selected and attacked cell
            
            guard let cell = fieldCtrl?.selectedCell else {
                return
            }
            
            let keySelectedCell = CellController().getKeyForCell(cell: cell)
            
            // Appends the cell to the set. Set will be assigned to a variable in the placingViewController to cache the progress
            changedCells.append((keySelectedCell, true))
            
            infoLabel.text = "Nice! Do That Again!"
            
            // Player can choose another cell
            if let gestureRecognizer = gestureRecognizer {
                fieldView?.addGestureRecognizer(gestureRecognizer)
            }
            
            fieldCtrl?.updateField(changedCells: changedCells)
            btnFire.isEnabled = true
            
            // Resets selected cell
            fieldCtrl?.selectedCell = nil
        }
        else {
            
            // Plays the sound that a ship was missed
            audioPlayer?.playMissed()
            
            stopTimer()
            
            // Sets the correct occurence for the attacked cell
            fieldCtrl?.selectedCell?.noShipOnCellAttackedOffender()
            
            guard let cell = fieldCtrl?.selectedCell else {
                return
            }
            
            // Gets the field position key of the selected cell
            let keySelectedCell = CellController().getKeyForCell(cell: cell)
            
            // Appends the cell to the set. Set will be assigned to a variable in the placingViewController to cache the progress
            changedCells.append((keySelectedCell, false))
            infoLabel.text = "You Missed!"
            
            // Start transition back to placing screen
            startDelay2Place()
        }
    }
    
    @objc func handleReduceShips(notification: NSNotification) {
        shipsLeftLabel.text = "\(Int(shipsLeftLabel?.text ?? "") ?? 0 - 1)"
        shipsLeftOpponent -= 1
    }

    private func startDelay2Place() {
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleDelay), userInfo: nil, repeats: true)
    }
    
    /** Time between the end of the attack phase and the transition back to the placing screen */
    @objc func handleDelay() {
        
        delayCount -= 1
        
        if delayCount == 0 {
            mTimer?.invalidate()
            delegate?.backFromAttackScreen(ctrl: self, changedCellsFromAttack: changedCells, shipsLeftOpponent: shipsLeftOpponent, lifeLeftOpponent: lifeLeftOpponent)
        }
    }
    
    // Button "Fire" was pressed
    @IBAction func firePressed(_ sender: UIButton) {
        
        if let cell = fieldCtrl?.selectedCell {
            // Fire was pressed an interaction gets disabled until the message of the opponent arrives (if a ship was attacked the interaction gets enabled again)
            if let gestureRecognizer = gestureRecognizer {
                fieldView.removeGestureRecognizer(gestureRecognizer)
            }
            
            sender.isEnabled = false
            
            // Gets the key for the attacked cell
            let key = CellController().getKeyForCell(cell: cell)
            
            // Sends a message to the opponent that a cell was attacked; its key as the second parameter
            mpcHandler?.sendMessage(key: "attack", additionalData: key)
        } else {
            infoLabel.textColor = .red
            infoLabel.text = "Choose A Target!"
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "attackVC2popUpOptionsVC" {
            
            let destVC = segue.destination as? PopUpOptionsViewController
            optionsScreen = destVC
            destVC?.delegate = self
        }
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name("didAttack"), object: nil)
        nc.removeObserver(self, name: NSNotification.Name("reduceShipsLeft"), object: nil)
    }
}
