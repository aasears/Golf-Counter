//
//  CounterViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

protocol receiveHoleNumber {
    func sendHoleIndex(holeIndex: Int, courseIndex: Int)
}

class CounterViewController: UIViewController, receiveHoleNumber {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let session = WCSession.default
    
    var golfHoleArray = [GolfGame]()
    var courseIndex = 0
    var index = 0
    
    @IBOutlet weak var holeTitle: UILabel!
    @IBOutlet weak var parCountLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var puttCountLabel: UILabel!
    @IBOutlet weak var previousHoleButton: UIButton!
    @IBOutlet weak var previousHoleImage: UIImageView!
    @IBOutlet weak var nextCourseButton: UIButton!
    @IBOutlet weak var nextCourseImage: UIImageView!
    @IBOutlet weak var nextHoleButton: UIButton!
    @IBOutlet weak var nextHoleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceived), name: NSNotification.Name(rawValue: "receivedWatchMessage"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFields()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCourseSummary" {
            let destinationVC = segue.destination as! GolfHoleViewController
            destinationVC.delegate = self
            destinationVC.courseIndex = courseIndex
        }
    }
    
    @objc func messageReceived(info: Notification) {
        let message = info.userInfo!
//        dispatch_async(dispatch_get_main_queue(), {
//
//        })
    }
    
    @IBAction func countButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            if (golfHoleArray[courseIndex].strokeCount?[index] ?? 0) < 99 {
                golfHoleArray[courseIndex].strokeCount?[index] += 1
            }
        } else if sender.tag == 2 {
            if (golfHoleArray[courseIndex].strokeCount?[index] ?? 0) > 0 &&
               (golfHoleArray[courseIndex].strokeCount?[index] ?? 0) > (golfHoleArray[courseIndex].puttCount?[index] ?? 0) {
                golfHoleArray[courseIndex].strokeCount?[index] -= 1
            }
        } else if sender.tag == 3 {
            if (golfHoleArray[courseIndex].strokeCount?[index] ?? 0) < 99 {
                golfHoleArray[courseIndex].puttCount?[index] += 1
                golfHoleArray[courseIndex].strokeCount?[index] += 1
            }
        } else if sender.tag == 4 {
            if (golfHoleArray[courseIndex].strokeCount?[index] ?? 0) > 0 && (golfHoleArray[courseIndex].puttCount?[index] ?? 0) > 0 {
                golfHoleArray[courseIndex].puttCount?[index] -= 1
                golfHoleArray[courseIndex].strokeCount?[index] -= 1
            }
        }
        
        loadFields()
    }
    
    @IBAction func saveAndChangeHole(_ sender: UIButton) {
        
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
    
    func sendHoleIndex(holeIndex: Int, courseIndex: Int) {
        self.index = holeIndex
        self.courseIndex = courseIndex
        loadFields()
    }
    
    func loadFields() {
        navigationItem.title = golfHoleArray[courseIndex].courseName
        holeTitle.text = "Hole \(index + 1)"
        parCountLabel.text = "\(golfHoleArray[courseIndex].parCount?[index] ?? 0)"
        strokeCountLabel.text = "\(golfHoleArray[courseIndex].strokeCount?[index] ?? 0)"
        puttCountLabel.text = "\(golfHoleArray[courseIndex].puttCount?[index] ?? 0)"
        
        if index == 0 {
            previousHoleButton.setTitle("", for: .normal)
            previousHoleImage.isHidden = true
            nextCourseButton.setTitle("", for: .normal)
            nextCourseButton.isEnabled = false
        } else if index == (golfHoleArray[courseIndex].strokeCount?.count ?? 0) - 1 {
            nextHoleButton.setTitle("", for: .normal)
            nextHoleImage.isHidden = true
            nextCourseButton.setTitle("Next Course", for: .normal)
            nextCourseButton.isEnabled = true
        } else {
            previousHoleButton.setTitle("Prev", for: .normal)
            previousHoleImage.isHidden = false
            nextHoleButton.setTitle("Next", for: .normal)
            nextHoleImage.isHidden = false
            nextCourseButton.setTitle("", for: .normal)
            nextCourseButton.isEnabled = false
        }
    }
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        let activePredicate = NSPredicate(format: "isActive == true")
        request.predicate = activePredicate
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

