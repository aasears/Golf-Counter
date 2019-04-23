//
//  GameSummaryViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 4/14/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class GameSummaryViewController: UIViewController {

    @IBOutlet weak var gameSummaryView: UIView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var netCountLabel: UILabel!
    @IBOutlet weak var puttCountLabel: UILabel!
    @IBOutlet weak var averageStrokesLabel: UILabel!
    @IBOutlet weak var averagePuttsLabel: UILabel!
    @IBOutlet weak var backToGameButton: UIButton!
    @IBOutlet weak var saveAndEndButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var golfHoleArray = [GolfGame]()
    var courseIndex = 0
    var currentDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        loadFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gameSummaryView.layer.cornerRadius = 15
        backToGameButton.layer.cornerRadius = 15
        saveAndEndButton.layer.cornerRadius = 15
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
//    for game in golfHoleArray {
//    context.delete(game)
//    }
    
    @IBAction func backToGameButtonPressed(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAndEndButtonPressed(_ sender: UIButton) {
        let finalGame = PastGolfGame(context: context)
        finalGame.dateFinished = Date()
        
        if golfHoleArray.count > 1 {
            finalGame.title = "\(golfHoleArray[0].courseName ?? "") (\(golfHoleArray.count))"
        } else {
            finalGame.title = golfHoleArray[0].courseName
        }
        
        for course in golfHoleArray {
            course.isActive = false
            course.history = finalGame
        }
        save()
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadFields() {
        var strokeCount = 0
        var puttCount = 0
        var netCount = 0
        var parCount = 0
        var averageStrokes = 0
        var averagePutts = 0
        if let holeCount = golfHoleArray[courseIndex].parCount?.count {
            for hole in 0..<holeCount {
                let par = golfHoleArray[courseIndex].parCount?[hole] ?? 0
                let stroke = golfHoleArray[courseIndex].strokeCount?[hole] ?? 0
                let putt = golfHoleArray[courseIndex].puttCount?[hole] ?? 0
                netCount += stroke - par
                parCount += par
                strokeCount += stroke
                puttCount += putt
            }
            averageStrokes = strokeCount / holeCount
            averagePutts = puttCount / holeCount
        }
        
        courseNameLabel.text = golfHoleArray[courseIndex].courseName
        dateLabel.text = currentDate
        strokeCountLabel.text = "\(strokeCount)"
        if netCount > 0 {
            netCountLabel.text = "+\(netCount)"
            netCountLabel.textColor = UIColor.red
        } else if netCount == 0 {
            netCountLabel.text = "\(netCount)"
            netCountLabel.textColor = UIColor.black
        } else {
            netCountLabel.text = "\(netCount)"
            netCountLabel.textColor = UIColor(red: 0, green: 0.56, blue: 0, alpha: 1)
        }
        puttCountLabel.text = "\(puttCount)"
        averageStrokesLabel.text = "\(averageStrokes)"
        averagePuttsLabel.text = "\(averagePutts)"
        if parCount == 0 {
            netCountLabel.text = ""
        }
    }
    
    func setDate() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.string(from: date)
    }
    
    func loadData() {
        
        setDate()
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
