//
//  SettingsInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 7/28/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation


class SettingsInterfaceController: WKInterfaceController {

    @IBOutlet var netScoreSwitch: WKInterfaceSwitch!
    
    var switchState = true
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        switchState = UserDefaults.standard.bool(forKey: "netSettingActive")
        setupSettingLayout()
        
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func netScoreChanged(_ value: Bool) {
        if switchState {
            switchState = false
        } else {
            switchState = true
        }
        netScoreSwitch.setOn(switchState)
        UserDefaults.standard.set(switchState, forKey: "netSettingActive")
    }
    
    func setupSettingLayout() {
        
        netScoreSwitch.setHeight(50)
        netScoreSwitch.setOn(switchState)
    }
    
}
