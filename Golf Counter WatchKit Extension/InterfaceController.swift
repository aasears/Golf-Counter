//
//  InterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var strokeCounter: WKInterfaceLabel!
    @IBOutlet var puttCounter: WKInterfaceLabel!
    
    var strokeCount = 0
    var puttCount = 0
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        
        strokeCounter.setText("\(strokeCount)")
        puttCounter.setText("\(puttCount)")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func plusStrokeButtonPressed() {
        strokeCount += 1
        strokeCounter.setText("\(strokeCount)")
    }
    
    @IBAction func minusStrokeButtonPressed() {
        strokeCount -= 1
        strokeCounter.setText("\(strokeCount)")
    }
    
    @IBAction func plusPuttButtonPressed() {
        puttCount += 1
        puttCounter.setText("\(puttCount)")
    }
    
    @IBAction func minusPuttButtonPressed() {
        puttCount -= 1
        puttCounter.setText("\(puttCount)")
    }
    
    
    
    

}
