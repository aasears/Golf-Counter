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
        
        setupDefaults()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        
        if segueIdentifier == "goToNewGame" {

        } else if segueIdentifier == "goToContinueGame" {
            UserDefaults.standard.set(true, forKey: "continueGame")
        }
        return nil
    }
    
    @IBAction func goToSettings() {
        presentController(withName: "settingsController", context: nil)
    }
    
    // MARK: - Startup Functions
    
    func setupDefaults() {
        guard UserDefaults.standard.value(forKey: "netSettingActive") != nil else {
            UserDefaults.standard.set(true, forKey: "netSettingActive")
            return
        }
    }
    
}
