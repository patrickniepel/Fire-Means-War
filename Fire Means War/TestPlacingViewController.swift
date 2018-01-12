//
//  TestPlacingViewController.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 03.05.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

// MARK: - Only for testing purposes

import UIKit

class TestPlacingViewController: UIViewController {
    
    var cells = [String : Cell]()
    var selectedCell : UIView?
    
    var fieldCtrl : FieldController!
    var shipCtrl : ShipController!
    var shipPosCtrl : ShipPositionController!


    @IBOutlet weak var fieldView: Field!
    @IBOutlet weak var btnFIre: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "709")!)
        
        
        btnFIre.layer.cornerRadius = 50
        
        //Testing function

        
        
        shipPosCtrl = ShipPositionController()
        
        
        
        
        
        //fieldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    override func viewDidLayoutSubviews() {
        fieldCtrl = FieldController(view: view, field: fieldView)
        fieldCtrl.setup(shipPosCtrl: shipPosCtrl)
        fieldCtrl.populateField()
        shipCtrl = ShipController()
        shipCtrl.setup(snapController: fieldCtrl.snapCtrl)
        shipCtrl.createShips(cellWidth: fieldCtrl.width, mainView: view, field: fieldView)
    }
    
//    func handleTap(gesture: UITapGestureRecognizer) {
//        
//        let location = gesture.location(in: fieldView)
//        
//        let width = fieldView.frame.width / CGFloat(fieldsPerRow)
//        let i = Int(location.x / width)
//        let j = Int(location.y / width)
//        print(i, j)
//        
//        let key = "\(i)|\(j)"
//        guard let cellView = cells[key] else {return}
//        
//        if selectedCell != cellView {
//            
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
//                self.selectedCell?.layer.transform = CATransform3DIdentity
//            }, completion: nil)
//        }
//        
//        selectedCell = cellView
//        
//        fieldView.bringSubview(toFront: cellView)
//        cellView.changeColor(aCase: .target)
//        
//        
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
//            
//            cellView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
//        }, completion: nil)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            for ship in shipCtrl.ships {
                
                if ship.frame.contains(touch.location(in: view)) {
                    
                    //MARK: Manchmal absturz wenn touch.view = cell
                    let ship = touch.view as? Ship
                    
                    if ship != nil {
                        ship!.center = touch.location(in: view)
                    }
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            for ship in shipCtrl.ships {
                
                if ship.frame.contains(touch.location(in: view)) {
                    
                    let ship = touch.view as? Ship
                    
                    if ship != nil {
                        fieldCtrl.checkSnapPosition(touchedShip: ship!)
//                        shipCtrl.checkForOverlapping(currentShip: ship!)
//                        shipCtrl.checkAnotherTimer()
                    }
                }
            }
        }
    }


}
