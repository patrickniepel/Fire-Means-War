//
//  AboutViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 03.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import StoreKit

/** ViewController for the about screen */
class AboutViewController: UIViewController {

    @IBOutlet weak var btnLicenses: UIButton!
    @IBOutlet weak var imageIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarWhite()
        
        btnLicenses.layer.cornerRadius = 5
        btnLicenses.layer.borderWidth = 1
        btnLicenses.layer.borderColor = UIColor.black.cgColor
        btnLicenses.backgroundColor = .white
        btnLicenses.setTitleColor(.black, for: .normal)
        
        imageIcon.layer.cornerRadius = 15
    }
    
    @IBAction func rate(_ sender: UIButton) {
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
