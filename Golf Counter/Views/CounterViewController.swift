//
//  CounterViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

protocol receiveHoleNumber {
    func sendHoleIndex(indexNumber: Int)
}

class CounterViewController: UIViewController, receiveHoleNumber {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var golfHoleArray = [GolfGame]()
    var currentCourse: GolfGame?
    var courseIndex = 0
    var index = 0
    
    @IBOutlet weak var holeTitle: UILabel!
    @IBOutlet weak var parCountLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var puttCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        currentCourse = golfHoleArray[courseIndex]
        navigationItem.title = currentCourse?.courseName
        loadFields()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCourseSummary" {
            let destinationVC = segue.destination as! GolfHoleViewController
            destinationVC.delegate = self
            destinationVC.courseIndex = courseIndex
        }
    }
    
    @IBAction func countButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            if (currentCourse?.strokeCount?[index] ?? 0) < 99 {
                currentCourse?.strokeCount?[index] += 1
            }
        } else if sender.tag == 2 {
            if (currentCourse?.strokeCount?[index] ?? 0) > 0 &&
               (currentCourse?.strokeCount?[index] ?? 0) > (currentCourse?.puttCount?[index] ?? 0) {
                currentCourse?.strokeCount?[index] -= 1
            }
        } else if sender.tag == 3 {
            if (currentCourse?.strokeCount?[index] ?? 0) < 99 {
                currentCourse?.puttCount?[index] += 1
                currentCourse?.strokeCount?[index] += 1
            }
        } else if sender.tag == 4 {
            if (currentCourse?.strokeCount?[index] ?? 0) > 0 && (currentCourse?.puttCount?[index] ?? 0) > 0 {
                currentCourse?.puttCount?[index] -= 1
                currentCourse?.strokeCount?[index] -= 1
            }
        }
        
        loadFields()
    }
    
    @IBAction func saveAndChangeHole(_ sender: UIButton) {
        
        golfHoleArray[courseIndex] = currentCourse ?? golfHoleArray[courseIndex]
        save()
        
        if sender.tag == 5 {
            
            if index < (golfHoleArray[courseIndex].strokeCount?.count ?? 0) - 1 {
                index += 1
                loadFields()
            }
            
        } else if sender.tag == 6 {
            
            if index > 0 {
                index -= 1
                loadFields()
            }
        }
    }
    
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func sendHoleIndex(indexNumber: Int) {
        index = indexNumber
        loadFields()
    }
    
    func loadFields() {
        holeTitle.text = "Hole \(index + 1)"
        parCountLabel.text = "\(golfHoleArray[courseIndex].parCount?[index] ?? 0)"
        strokeCountLabel.text = "\(golfHoleArray[courseIndex].strokeCount?[index] ?? 0)"
        puttCountLabel.text = "\(golfHoleArray[courseIndex].puttCount?[index] ?? 0)"
    }
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        let sort = NSSortDescriptor(key: "orderIdentifier", ascending: true)
        request.sortDescriptors = [sort]
        
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

