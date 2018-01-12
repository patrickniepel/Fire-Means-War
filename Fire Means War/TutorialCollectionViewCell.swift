//
//  TutorialCollectionViewCell.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 27.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class TutorialCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialText: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        tutorialImage.layer.borderWidth = 7
        tutorialImage.layer.borderColor = UIColor.orange.cgColor
        tutorialImage.layer.cornerRadius = 10
    }
}
