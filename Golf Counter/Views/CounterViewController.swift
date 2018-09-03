//
//  CounterViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {

    var strokeCount: Int = 0
    let parCount: Int = 0
    
    @IBOutlet weak var countTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func countButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            strokeCount += 1
        } else if sender.tag == 2 {
            strokeCount -= 1
        }
        
        countTextField.text = String(strokeCount)
    }
    
    @IBAction func test(_ sender: Any) {
    }
    

}

