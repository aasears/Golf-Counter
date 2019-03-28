//
//  editCourseHoleTableViewCell.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import Foundation
import UIKit

protocol editCourseHoleTableViewCellDelegate {
    
    func increasePar(holeNumber: Int)
    func decreasePar(holeNumber: Int)
}

class editCourseHoleTableViewCell: UITableViewCell {

    @IBOutlet weak var holeNumLabel: UILabel!
    @IBOutlet weak var parLabel: UILabel!
    var holeNumber = 0
    var parNumber = 0
    
    var delegate: editCourseHoleTableViewCellDelegate?
    
    func setHoleDetails(holeNum: Int, par: Int) {
        holeNumber = holeNum
        parNumber = par
        setFields()
    }
    
    func setFields() {
        holeNumLabel.text = String(holeNumber)
        parLabel.text = String(parNumber)
    }
    
    
    @IBAction func increaseParTapped(_ sender: UIButton) {
        
        delegate?.increasePar(holeNumber: holeNumber)
        parNumber += 1
        setFields()
    }
    
    @IBAction func decreaseParTapped(_ sender: UIButton) {
        
        delegate?.decreasePar(holeNumber: holeNumber)
        parNumber -= 1
        setFields()
    }
    
}
