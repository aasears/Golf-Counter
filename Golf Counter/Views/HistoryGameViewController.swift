//
//  HistoryGameViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 6/30/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class HistoryGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, holeTableViewCellDelegate {
    
        @IBOutlet weak var parTitleLabel: UILabel!
        @IBOutlet weak var netTitleLabel: UILabel!
        @IBOutlet weak var holeSummaryTableView: UITableView!
        @IBOutlet weak var parTotalLabel: UILabel!
        @IBOutlet weak var strokesTotalLabel: UILabel!
        @IBOutlet weak var netTotalLabel: UILabel!
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
        var pastGolfGame = PastGolfGame()
        var golfHoleArray = [GolfGame]()
        var continueGame = false
        var courseIndex = 0
        var blurEffect: UIVisualEffect!
        
        var delegate: receiveHoleNumber?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            loadData()
            holeSummaryTableView.delegate = self
            holeSummaryTableView.dataSource = self
        }
        
        override func viewWillAppear(_ animated: Bool) {
            loadFields()
        }
        
        // MARK: - Table view data source
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if golfHoleArray.count > 0 {
                return golfHoleArray[courseIndex].strokeCount?.count ?? 0
            } else {
                return 0
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "holeTableViewCell", for: indexPath) as! holeTableViewCell
            let index = courseIndex
            
            let strokes = golfHoleArray[index].strokeCount?[indexPath.row] ?? 0
            let par = golfHoleArray[index].parCount?[indexPath.row] ?? 0
            let putt = golfHoleArray[index].puttCount?[indexPath.row] ?? 0
            
            cell.accessoryType = .disclosureIndicator
            cell.setHoleFields(hole: indexPath.row + 1, stroke: strokes, par: par, putt: putt)
            
            return cell
        }
    
        //MARK: - TableView Delegate Methods
        
        func setupButtons() {
//            nextCourseButton.layer.cornerRadius = 15
//            finishGameButton.layer.cornerRadius = 15
//            if golfHoleArray.count <= 1 {
//                nextCourseButton.isHidden = true
//            }
        }
        
        func displayTotals() {
            var parSum = 0
            var strokeSum = 0
            var netSum = 0
            if let holeCount = golfHoleArray[courseIndex].parCount?.count {
                for hole in 0..<holeCount {
                    let par = golfHoleArray[courseIndex].parCount?[hole] ?? 0
                    let stroke = golfHoleArray[courseIndex].strokeCount?[hole] ?? 0
                    if par > 0 && stroke > 0 {
                        netSum += stroke - par
                        parSum += par
                    }
                    if stroke > 0 {
                        strokeSum += stroke
                    }
                }
            }
            if parSum > 0 {
                parTotalLabel.text = "\(parSum)"
                netTotalLabel.text = "\(netSum)"
                netTitleLabel.text = "Net"
                if netSum > 0 {
                    netTotalLabel.text = "+\(netSum)"
                    netTotalLabel.textColor = UIColor.red
                } else if netSum < 0 {
                    netTotalLabel.textColor = UIColor.green
                } else {
                    netTotalLabel.textColor = UIColor.white
                }
            } else {
                parTotalLabel.text = "\(parSum)"
                netTotalLabel.text = ""
                netTitleLabel.text = ""
            }
            strokesTotalLabel.text = "\(strokeSum)"
            
        }
        
        func loadFields() {
            navigationItem.title = golfHoleArray[courseIndex].courseName
            holeSummaryTableView.reloadData()
            setupButtons()
            displayTotals()
        }
        
        // MARK: - CoreData functions
        
        func loadData() {
            
            let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
            let activePredicate = NSPredicate(format: "history == %@", pastGolfGame)
            request.predicate = activePredicate
            let sort = NSSortDescriptor(key: "orderIdentifier", ascending: true)
            request.sortDescriptors = [sort]
            
            do {
                golfHoleArray = try context.fetch(request)
            } catch {
                print("Error fetching context \(error)")
            }
        }
    
        
}
