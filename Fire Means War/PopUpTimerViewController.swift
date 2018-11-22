//
//  PopUpTimerViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 08.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

protocol PopUpTimerDelegate {
    func backFromPopUpView(ctrl: PopUpTimerViewController)
}

/** PopUp-Screen for 5sec timer before the match starts */
class PopUpTimerViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var ivWood: UIImageView!
    
    var count = 5
    var mTimer : Timer?
    
    var delegate : PopUpTimerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel.text = String(count)
        
        ivWood.layer.cornerRadius = 25
        ivWood.layer.borderWidth = 2
        ivWood.layer.borderColor = UIColor.white.cgColor
        
        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mTimer?.invalidate()
    }
    
    /** 5secs timer before the match really starts */
    @objc func handleTimer() {
        
        count -= 1
        
        if count == 0 {
            mTimer?.invalidate()
            delegate?.backFromPopUpView(ctrl: self)
        }
        else {
            timerLabel.text = String(count)
        }
    }
}
