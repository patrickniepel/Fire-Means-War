//
//  PauseViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 12.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

protocol PauseSegueDelegate {
    func backFromPauseScreen(ctrl: PauseViewController)
}

class PauseViewController: UIViewController {
    
    var delegate : PauseSegueDelegate? = nil

    @IBOutlet weak var ivPause: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivPause.layer.cornerRadius = 25
        ivPause.layer.borderWidth = 2
        ivPause.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func resumeMatch(_ sender: UIButton) {
        delegate?.backFromPauseScreen(ctrl: self)
    }
}
