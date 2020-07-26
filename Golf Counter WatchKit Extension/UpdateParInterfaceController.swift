//
//  UpdateParInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 7/26/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

protocol ParUpdateDelegate {
    func didUpdateParValue(newParValue: Int)
    
}

class UpdateParInterfaceController: WKInterfaceController {
 
    @IBOutlet weak var parLabel: WKInterfaceLabel!

    var delegate: NewCourseInterfaceController? = nil
    var parValue = 0
      
    override func awake(withContext context: Any?) {
        let passedContext = context as? contextForPar
        
        delegate = passedContext?.delegate as? NewCourseInterfaceController
        
        if let par: Int = passedContext?.parValue {
            parValue = par
        }
        parLabel.setText("\(parValue)")
        
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Update Par Methods
    
    @IBAction func addParButton() {
        if parValue < 99 {
            parValue += 1
            parLabel.setText("\(parValue)")
        }
    }
    
    @IBAction func subtParButton() {
        if parValue > 0 {
            parValue -= 1
            parLabel.setText("\(parValue)")
        }
    }
    
    @IBAction func saveButton() {
        delegate?.didUpdateParValue(newParValue: parValue)
        dismiss()
    }
    
    
}
