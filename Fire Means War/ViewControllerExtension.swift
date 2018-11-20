//
//  ViewControllerExtension.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 06.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupNavigationBarTranslucent() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                        NSAttributedString.Key.font: UIFont.init(name: "Philosopher-Bold", size: 21)!]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupNavigationBarWhite() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                        NSAttributedString.Key.font: UIFont.init(name: "Philosopher-Bold", size: 21)!]
    }
}
