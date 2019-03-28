//
//  CounterViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData


//protocol CanReceive {
//
//    func dataReceived(data: GolfCounter, index: Int)
//}

class CounterViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var golfHoleArray = [GolfGame]()
    var index: Int = 0
    
    @IBOutlet weak var holeTitle: UILabel!
    @IBOutlet weak var totalCountTextField: UITextField!
    @IBOutlet weak var strokeCountTextField: UITextField!
    @IBOutlet weak var puttCountTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        loadFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func countButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            golfHoleArray[0].strokeCount?[index] += 1
        } else if sender.tag == 2 {
            golfHoleArray[0].strokeCount?[index] -= 1
        } else if sender.tag == 3 {
            golfHoleArray[0].puttCount?[index] += 1
            golfHoleArray[0].strokeCount?[index] += 1
        } else if sender.tag == 4 {
            golfHoleArray[0].puttCount?[index] -= 1
            golfHoleArray[0].strokeCount?[index] -= 1
        }
        
        golfHoleArray[0].totalCount?[index] = golfHoleArray[0].strokeCount?[index] ?? 0 //+ golfHoleArray[index].puttCount
        
        loadFields()
    }
    
    @IBAction func saveAndChangeHole(_ sender: UIButton) {
        
        save()
        
        if sender.tag == 5 {
            
            if index < (golfHoleArray[0].totalCount?.count ?? 0) - 1 {
                index += 1
                loadFields()
            }
            
        } else if sender.tag == 6 {
            
            if index > 0 {
                index -= 1
                loadFields()
            }
            
        } else if sender.tag == 7 {
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func loadFields() {
        holeTitle.text = "Hole \(index + 1)"
        totalCountTextField.text = "\(golfHoleArray[0].parCount?[index] ?? 0)"
        strokeCountTextField.text = "\(golfHoleArray[0].strokeCount?[index] ?? 0)"
        puttCountTextField.text = "\(golfHoleArray[0].puttCount?[index] ?? 0)"
    }
    
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        
        do {
            golfHoleArray = try context.fetch(request)
        } catch {
            print("Error fetching context \(error)")
        }
    }
    
    
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    

}

