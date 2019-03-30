//
//  MainMenuViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToContinueGame" {
            
            let destinationVC = segue.destination as! GolfHoleViewController
            
            destinationVC.continueGame = true
        }
    }
    
    @IBAction func continueGame(_ sender: UIButton) {
        performSegue(withIdentifier: "goToContinueGame", sender: self)
    }
    



}
