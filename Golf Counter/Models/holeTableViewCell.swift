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
    @IBOutlet weak var netCount: UILabel!
    
    func setHoleFields(hole: Int, stroke: Int, par: Int, putt: Int) {
        //putt currently represents stroke - par
        holeNum.text = "\(hole)"
        strokeCount.text = "\(stroke)"
        parCount.text = "\(par)"
        
        if stroke == 0 || par == 0 {
            netCount.text = ""
        } else if (stroke - par) > 0 {
            netCount.textColor = UIColor.red
            netCount.text = "+\(stroke - par)"
        } else if (stroke - par) < 0 {
            netCount.textColor = UIColor(red: 0, green: 0.56, blue: 0, alpha: 1)
            netCount.text = "\(stroke - par)"
        } else {
            netCount.textColor = UIColor.black
            netCount.text = "\(stroke - par)"
        }
    }
}
