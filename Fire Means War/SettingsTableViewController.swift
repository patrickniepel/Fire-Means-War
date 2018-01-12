//
//  SettingsTableViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 10.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet var shipButtons: [UIButton]!
    
    
    var chosenShip = 0
    
    var audioPlayer : AudioPlayer!
    var volume : Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarWhite()
        
        loadLayout()
        
        // Sets the current volume of the audioPlayer
        volume = audioPlayer.audioPlayer!.volume
        
        slider.value = volume
    }

    @IBAction func volumeDragged(_ sender: UISlider) {
        volume = sender.value
        audioPlayer.setVolume(vol: volume)
    }
    
    @IBAction func layoutTapped(_ sender: UIButton) {
        
        
        for button in shipButtons {
            if button.layer.borderWidth == 2 {
                button.layer.borderWidth = 0
            }
        }
        
        sender.layer.borderColor = UIColor.blue.cgColor
        sender.layer.borderWidth = 2
        chosenShip = shipButtons.index(of: sender)!
        saveLayout()
    }
    
    fileprivate func loadLayout() {
        
        chosenShip = UserDefaults.standard.integer(forKey: "shipLayout")
        setLayout()
    }
    
    fileprivate func setLayout() {
        
        for button in shipButtons {
            
            if button == shipButtons[chosenShip] {
                button.layer.borderColor = UIColor.blue.cgColor
                button.layer.borderWidth = 2
            }
            else {
                button.layer.borderColor = UIColor.blue.cgColor
                button.layer.borderWidth = 0
            }
        }
    }
    
    // Save volume
    // If player sets the volume to 0 -> value of -1 gets saved
    // 0 would be the default value when there is no value saved in the UserDefaults
    fileprivate func saveVolume() {
        if volume == 0 {
            UserDefaults.standard.set(-1, forKey: "volume")
        }
        else {
            UserDefaults.standard.set(volume, forKey: "volume")
        }
    }
    
    fileprivate func saveLayout() {
        UserDefaults.standard.set(chosenShip, forKey: "shipLayout")
    }
}
