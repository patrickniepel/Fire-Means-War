//
//  TutorialDataSource.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 27.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class TutorialDataSource: NSObject, UICollectionViewDataSource {
    
    var tutorialCtrl : TutorialController!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tutorialCtrl.getNumberOfTutorialPages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorialCell", for: indexPath) as! TutorialCollectionViewCell
        
        let tutorialData = tutorialCtrl.getTutorialPage(for: indexPath.item)
        
        cell.tutorialImage.image = tutorialData.0
        cell.tutorialText.text = tutorialData.1
        cell.setup()
        
        return cell
    }
}
