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
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        
        if segueIdentifier == "goToNewNineHoleGame" {
            UserDefaults.standard.set("9 Hole Course", forKey: "course")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "strokes")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "putts")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0], forKey: "par")
            UserDefaults.standard.set(Date(), forKey: "dateCreated")
            UserDefaults.standard.set(0, forKey: "orderIdentifier")
        } else if segueIdentifier == "goToNewEighteenHoleGame" {
            UserDefaults.standard.set("18 Hole Course", forKey: "course")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "strokes")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "putts")
            UserDefaults.standard.set([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], forKey: "par")
            UserDefaults.standard.set(Date(), forKey: "dateCreated")
            UserDefaults.standard.set(0, forKey: "orderIdentifier")
        } else if segueIdentifier == "goToContinueGame" {
            
        }
        return nil
    }

}
