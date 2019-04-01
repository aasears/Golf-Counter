//
//  NewGameViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/31/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {

    @IBOutlet weak var selectMultipleButton: UIButton!
    @IBOutlet weak var courseSelectionTableView: UITableView!
    
    let sections = ["Standard Game", "Courses"]
    let standardGameOptions = ["9 Holes", "18 Holes"]
    
    var courseArray = [Course]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //courseSelectionTableView.dataSource = NewGameTableViewController
    }
    

    @IBAction func selectMultipleButtonPressed(_ sender: UIButton) {
        
        courseSelectionTableView.allowsMultipleSelection = true
        selectMultipleButton.setTitle("Let's Play", for: .normal)
    }
    
}
