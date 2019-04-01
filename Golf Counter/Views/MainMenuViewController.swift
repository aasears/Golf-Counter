//
//  MainMenuViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class MainMenuViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var golfHoleArray = [GolfGame]()

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
        
        loadData()
        
        if golfHoleArray.count == 0 {
            performSegue(withIdentifier: "goToSelectCourse", sender: self)
        } else {
            performSegue(withIdentifier: "goToContinueGame", sender: self)
        }
    }
    
    // MARK: - CoreData functions
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        
        do {
            golfHoleArray = try context.fetch(request)
        } catch {
            print("Error fetching context \(error)")
        }
    }


}
