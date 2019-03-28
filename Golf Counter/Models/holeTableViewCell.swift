//
//  holeTableViewCell.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/21/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import Foundation
import UIKit

protocol holeTableViewCellDelegate {
    
}

class holeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var holeIcon: UIImageView!
    @IBOutlet weak var holeNum: UILabel!
    @IBOutlet weak var strokeCount: UILabel!
    @IBOutlet weak var parCount: UILabel!
    @IBOutlet weak var puttCount: UILabel!
    
    func setHoleFields(hole: Int, stroke: Int, par: Int, putt: Int) {
        //putt currently represents stroke - par
        holeNum.text = "\(hole)"
        strokeCount.text = "\(stroke)"
        parCount.text = "\(par)"
        
        if stroke == 0 {
            puttCount.text = ""
        } else {
            puttCount.text = "\(stroke - par)"
        }
        
        if (stroke - par) > 0 {
            puttCount.textColor = UIColor.red
            puttCount.text = "+\(stroke - par)"
        } else if (stroke - par) < 0 {
            puttCount.textColor = UIColor.green
        } else {
            puttCount.textColor = UIColor.black
        }
    }
    

    
}
