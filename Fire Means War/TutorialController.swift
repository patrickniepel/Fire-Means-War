//
//  TutorialController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 27.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class TutorialController: NSObject {
    
    var tutorialPages : [(UIImage, String)] = [
        (#imageLiteral(resourceName: "page1"), "\n\"A red border indicates that the ship was not placed correctly\""),
        (#imageLiteral(resourceName: "page2"), "\n\"Drag a ship onto the field and double tap to rotate it\""),
        (#imageLiteral(resourceName: "page3"), "\n\"Between each ship has to be a space of 1\""),
        (#imageLiteral(resourceName: "page4"), "\n\"Tap on a cell to select it as your target\""),
        (#imageLiteral(resourceName: "page5"), "\n\"Tap on 'Fire' to start your attack\""),
        (#imageLiteral(resourceName: "page6"), "\n\"You can keep firing as long as you are hitting ships and the timer has not reached 0 yet\"")
    ]
    
    func getNumberOfTutorialPages() -> Int {
        return tutorialPages.count
    }
    
    func getTutorialPage(for index: Int) -> (UIImage, String) {
        return tutorialPages[index]
    }
}
