//
//  TutorialDelegateFlowLayout.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 27.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class TutorialDelegateFlowLayout: NSObject, UICollectionViewDelegateFlowLayout {
    
    var tutorialCtrl : TutorialController?
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
}
