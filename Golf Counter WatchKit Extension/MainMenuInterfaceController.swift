//
//  MainMenuInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 5/19/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation


class MainMenuInterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        
        if segueIdentifier == "goToNewNineHoleGame" {
            newGame(numberOfHoles: 9, withCourseName: "9 Hole Course")
        } else if segueIdentifier == "goToNewEighteenHoleGame" {
            newGame(numberOfHoles: 18, withCourseName: "18 Hole Course")
        } else if segueIdentifier == "goToContinueGame" {
            
        }
        return nil
    }
    
    func newGame(numberOfHoles: Int, withCourseName: String) {
        
        UserDefaults.standard.set(withCourseName, forKey: "course")
        UserDefaults.standard.set(Date(), forKey: "dateCreated")
        UserDefaults.standard.set(0, forKey: "orderIdentifier")
        
        if numberOfHoles == 9 {
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "strokes")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "putts")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "par")
        } else if numberOfHoles == 18 {
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "strokes")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "putts")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "par")
        }
    }
    
    

}
