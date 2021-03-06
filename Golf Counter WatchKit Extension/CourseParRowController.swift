//
//  CourseParRowController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 7/25/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchKit

class CourseParRowController: NSObject {
    
    @IBOutlet weak var holeCountLabel: WKInterfaceLabel!
    @IBOutlet weak var holeParLabel: WKInterfaceLabel!
        
    var hole: Int? {
        
        didSet {
            guard let hole = hole else {return}
            
            holeCountLabel.setText("\(hole)")
        }
    }
    
    var par: Int? {
        
        didSet {
            guard let par = par else {return}
            
            holeParLabel.setText("\(par)")
        }
    }
}
