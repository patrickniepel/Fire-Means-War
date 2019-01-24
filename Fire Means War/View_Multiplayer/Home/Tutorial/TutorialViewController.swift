//
//  TutorialViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 27.10.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    var currentPage = 0
    var totalPages = 0
    var tutorialCtrl : TutorialController?
    
    var dataSource : TutorialDataSource?
    var delegate : TutorialDelegateFlowLayout?
    var leftSwipe : UISwipeGestureRecognizer?
    var rightSwipe : UISwipeGestureRecognizer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarWhite()
        
        tutorialCtrl = TutorialController()
        
        totalPages = tutorialCtrl?.getNumberOfTutorialPages() ?? 0
        
        dataSource = TutorialDataSource()
        delegate = TutorialDelegateFlowLayout()
        
        dataSource?.tutorialCtrl = tutorialCtrl
        delegate?.tutorialCtrl = tutorialCtrl
        collectionView?.dataSource = dataSource
        collectionView?.delegate = delegate
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        updatePageControl(page: 0)
        
        guard let leftSwipe = leftSwipe, let rightSwipe = rightSwipe else {
            return
        }
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        collectionView.addGestureRecognizer(leftSwipe)
        collectionView.addGestureRecognizer(rightSwipe)
        
        
    }
    
    func updatePageControl(page: Int) {
        currentPage = page
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = totalPages
    }
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            nextPage()
        }
        if gesture.direction == .right {
            prevPage()
        }
    }

    func prevPage() {
        
        if currentPage - 1 < 0 {
            return
        }
        currentPage -= 1
        
        updatePageControl(page: currentPage)
        
        let prevItem: IndexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: prevItem, at: .left, animated: true)
    }
    
    func nextPage() {
        
        if currentPage + 1 == totalPages {
            return
        }
        currentPage += 1
        
        updatePageControl(page: currentPage)
        
        let nextItem: IndexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: nextItem, at: .right, animated: true)
    }

}
