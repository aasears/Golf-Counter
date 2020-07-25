//
//  MainMenuInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 5/19/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class MainMenuInterfaceController: WKInterfaceController {

    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setupDefaults()
    }

    override func willActivate() {
        super.willActivate()
        
        switch UserDefaults.standard.string(forKey: "navigationState") {
        case "selectMultiCourse":
            print("test1")
            UserDefaults.standard.set("onSelectMultiCourse", forKey: "navigationState")
            presentController(withName: "MultipleCourseInterfaceController", context: nil)
        case "startMultiCourse":
            print("test2")
            UserDefaults.standard.set("onStartMultiCourse", forKey: "navigationState")
            UserDefaults.standard.set(true, forKey: "multiCourse")
            pushController(withName: "NewGameInterfaceController", context: nil)
        default:
            print("value not handled forKey: 'selectMultiCourse'. Printed \(UserDefaults.standard.string(forKey: "navigationState") ?? "nothing to print")")
        }
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
        UserDefaults.standard.set(false, forKey: "mainMenu")
    }
    
}
