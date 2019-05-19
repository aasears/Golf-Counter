//
//  SummaryRowController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 5/19/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit

class SummaryRowController: NSObject {

    @IBOutlet var holeNumberLabel: WKInterfaceLabel!
    @IBOutlet var strokeCountLabel: WKInterfaceLabel!
    
    var hole: Int? {
        
        didSet {
            guard let hole = hole else {return}
            
            holeNumberLabel.setText("\(hole)")
        }
    }
    
    var strokes: Int? {
        
        didSet {
            guard let strokes = strokes else {return}
            
            strokeCountLabel.setText("\(strokes)")
        }
    }
}
