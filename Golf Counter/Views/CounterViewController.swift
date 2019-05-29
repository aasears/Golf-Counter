//
//  CounterViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import WatchConnectivity

protocol receiveHoleNumber {
    func sendHoleIndex(holeIndex: Int, courseIndex: Int)
}

class CounterViewController: UIViewController, receiveHoleNumber {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let session = WCSession.default
    
    var golfHoleArray = [GolfGame]()
    var courseIndex = 0
    var index = 0
    
    @IBOutlet weak var holeTitle: UILabel!
    @IBOutlet weak var parCountLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var puttCountLabel: UILabel!
    @IBOutlet weak var previousHoleButton: UIButton!
    @IBOutlet weak var previousHoleImage: UIImageView!
    @IBOutlet weak var nextHoleButton: UIButton!
    @IBOutlet weak var nextHoleImage: UIImageView!
    @IBOutlet weak var nextCourseButton: UIButton!
    @IBOutlet weak var finishGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        //NotificationCenter.default.addObserver(self, selector: #selector(messageReceived), name: NSNotification.Name(rawValue: "ReceivedWatchMessage"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFields()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCourseSummary" {
            let destinationVC = segue.destination as! GolfHoleViewController
            destinationVC.delegate = self
            destinationVC.courseIndex = courseIndex
        } else if segue.identifier == "toNextCourse" {
            let destinationVC = segue.destination as! NextCourseViewController
            destinationVC.onSelection = { (courseIndex) in
                self.courseIndex = courseIndex
                self.index = 0
                self.loadFields()
            }
        } else if segue.identifier == "toGameSummary" {
            let destinationVC = segue.destination as! GameSummaryViewController
            destinationVC.onFinish = { (finsihed) in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    
//    @objc func messageReceived(info: Notification) {
//        let message = info.userInfo!
//
//        parCountLabel.text = message["Msg"] as? String
//    }
    
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
    
//    func sendToWatch() {
//        if self.session.isPaired == true && self.session.isWatchAppInstalled {
//            self.session.sendMessage(["Msg" : "9"], replyHandler: nil, errorHandler: nil)
//        }
//    }
    
    func loadFields() {
        navigationItem.title = golfHoleArray[courseIndex].courseName
        holeTitle.text = "Hole \(index + 1)"
        if (golfHoleArray[courseIndex].parCount?[index] ?? 0) == 0 {
            parCountLabel.text = ""
        } else {
            parCountLabel.text = "Par \(golfHoleArray[courseIndex].parCount?[index] ?? 0)"
        }
        strokeCountLabel.text = "\(golfHoleArray[courseIndex].strokeCount?[index] ?? 0)"
        puttCountLabel.text = "\(golfHoleArray[courseIndex].puttCount?[index] ?? 0)"
        
        nextCourseButton.layer.cornerRadius = 15
        finishGameButton.layer.cornerRadius = 15
        
        if index == 0 {
            previousHoleButton.setTitle("", for: .normal)
            previousHoleImage.isHidden = true
            nextHoleButton.setTitle("Next", for: .normal)
            nextHoleImage.isHidden = false
            nextCourseButton.isHidden = true
            finishGameButton.isHidden = true
        } else if index == (golfHoleArray[courseIndex].strokeCount?.count ?? 0) - 1 {
            nextHoleButton.setTitle("", for: .normal)
            nextHoleImage.isHidden = true
            finishGameButton.isHidden = false
            if golfHoleArray.count > 1 {
                nextCourseButton.isHidden = false
            }
        } else {
            previousHoleButton.setTitle("Prev", for: .normal)
            previousHoleImage.isHidden = false
            nextHoleButton.setTitle("Next", for: .normal)
            nextHoleImage.isHidden = false
            nextCourseButton.isHidden = true
            finishGameButton.isHidden = true
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
        
        //sendToWatch()
    }

}

