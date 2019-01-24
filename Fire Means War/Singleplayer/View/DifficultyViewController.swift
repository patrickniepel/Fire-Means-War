//
//  DifficultyViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 14.09.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

protocol DifficultySegueDelegate {
    func backFromDifficultyScreen(ctrl: DifficultyViewController, message: String)
}

class DifficultyViewController: UIViewController, SPPlacingSegueDelegate {
    
    @IBOutlet var buttons: [UIButton]!
    
    var audioPlayer : AudioPlayer?
    var delegate : DifficultySegueDelegate? = nil

    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarTranslucent()
        backgroundImage.image = #imageLiteral(resourceName: "testMainMirror")
        
        setupButtons()
    }
    
    private func setupButtons() {
    
        for button in buttons {
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2
        }
    }

    @IBAction func difficultyTapped(_ sender: UIButton) {
        
        //Difficulty Tags (100,101,102)
        let difficulty = sender.tag % 100
        
        // Stop main theme
        audioPlayer?.volumeToZero()
        perform(#selector(stopPlayer), with: nil, afterDelay: 2)
        
        performSegue(withIdentifier: "difficultyVC2spPlacingVC", sender: difficulty)
    }
    
    /** Stops the main theme */
    @objc func stopPlayer() {
        audioPlayer?.stop()
    }
    
    private func getDifficultyString(difficulty: Int) -> String {
        
        if difficulty == 0 {
            return "Easy"
        }
        if difficulty == 1 {
            return "Medium"
        }
        else {
            return "Hard"
        }
    }
    
    func backFromSPPlacingScreen(ctrl: SPPlacingViewController, message: String) {
        ctrl.navigationController?.popViewController(animated: false)
        delegate?.backFromDifficultyScreen(ctrl: self, message: message)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "difficultyVC2spPlacingVC" {
            
            let destVC = segue.destination as? SPPlacingViewController
            
            let difficulty = sender as? Int ?? 0
            
            destVC?.delegate = self
            destVC?.difficulty = difficulty
            destVC?.difficultyTitle = getDifficultyString(difficulty: difficulty)
            destVC?.audioPlayer = audioPlayer
        }
    }
}
