//
//  PopUpOptionsViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 20.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

protocol OptionsDelegate {
    func concedeFromOptionsView(ctrl: PopUpOptionsViewController)
    func continueFromOptionsView(ctrl: PopUpOptionsViewController)
}

/** PopUp-Screen for "Concede" and "Continue" (Options menu during the match) */
class PopUpOptionsViewController: UIViewController {

    @IBOutlet weak var ivWood: UIImageView!
    
    var delegate : OptionsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivWood.layer.cornerRadius = 25
        ivWood.layer.borderWidth = 2
        ivWood.layer.borderColor = UIColor.white.cgColor
    }
    
    // Concede button gets tapped
    @IBAction func concede(_ sender: UIButton) {
        delegate!.concedeFromOptionsView(ctrl: self)
    }
    
    // Continue button gets tapped
    @IBAction func continueMatch(_ sender: UIButton) {
        delegate!.continueFromOptionsView(ctrl: self)
    }
}
