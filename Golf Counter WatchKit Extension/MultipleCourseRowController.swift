//
//  MultipleCourseRowController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 1/12/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchKit

class MultipleCourseRowController: NSObject {
    
    @IBOutlet var courseNameLabel: WKInterfaceLabel!
    @IBOutlet var holeCountLabel: WKInterfaceLabel!
    @IBOutlet weak var orderIdentifierLabel: WKInterfaceLabel!
    
    
    var course: String? {
        
        didSet {
            guard let course = course else {return}
            
            courseNameLabel.setText("\(course)")
        }
    }
    
    var count: Int? {
        
        didSet {
            guard let count = count else {return}
            
            holeCountLabel.setText("\(count) holes")
        }
    }
    
    var order: Int? {
        
        didSet {
            guard let order = order else {return}
            
            orderIdentifierLabel.setText("\(order)")
        }
    }
}
