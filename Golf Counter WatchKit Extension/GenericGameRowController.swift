//
//  GenericGameRowController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit

class GenericGameRowController: NSObject {
    
    @IBOutlet var courseNameLabel: WKInterfaceLabel!
    
    var course: String? {
        
        didSet {
            guard let course = course else {return}
            
            courseNameLabel.setText("\(course)")
        }
    }
    
    
}
