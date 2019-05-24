//
//  HeaderowController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 5/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit

class HeaderRowController: NSObject {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var titleCountLabel: WKInterfaceLabel!
    
    var title: String? {
        
        didSet {
            guard let title = title else {return}
            
            titleLabel.setText("\(title)")
        }
    }
    
    var count: Int? {
        
        didSet {
            guard let count = count else {return}
            
            titleCountLabel.setText("\(count)")
        }
    }
}
