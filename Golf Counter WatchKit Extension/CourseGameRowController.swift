//
//  CourseGameController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit

class CourseGameRowController: NSObject {
    
    @IBOutlet var courseNameLabel: WKInterfaceLabel!
    @IBOutlet var holeCountLabel: WKInterfaceLabel!
    
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
}
