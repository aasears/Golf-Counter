//
//  GolfHoleViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/3/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class GolfHoleViewController: UITableViewController, holeTableViewCellDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var golfHoleArray = [GolfGame]()
    var courseArray = [Course]()
    var index = 0
    var section = 0
    var continueGame = false

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        loadCourses()
        
        if !continueGame {
            startNewGame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        navigationItem.title = golfHoleArray[0].courseName
    }

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if golfHoleArray.count > 0 {
            return golfHoleArray[0].totalCount?.count ?? 0
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holeTableViewCell", for: indexPath) as! holeTableViewCell
        
        cell.setHoleFields(
            hole: indexPath.row + 1,
            stroke: golfHoleArray[0].totalCount?[indexPath.row] ?? 0,
            par: golfHoleArray[0].parCount?[indexPath.row] ?? 0,
            putt: golfHoleArray[0].puttCount?[indexPath.row] ?? 0)
        
        
        if ((golfHoleArray[0].totalCount?[indexPath.row] ?? 0) - (golfHoleArray[0].parCount?[indexPath.row] ?? 0)) > 0 {
            cell.puttCount.textColor = UIColor.red
        } else if ((golfHoleArray[0].totalCount?[indexPath.row] ?? 0) - (golfHoleArray[0].parCount?[indexPath.row] ?? 0)) < 0 {
            cell.puttCount.textColor = UIColor.green
        } else {
            cell.puttCount.textColor = UIColor.black
        }
        
        return cell
    }

    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCounter", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCounter" {
            
            let destinationVC = segue.destination as! CounterViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.index = indexPath.row
            }
        }
    }
    
    // MARK: - Game functions
    
    func startNewGame() {
        
        if golfHoleArray.count > 0 {
            context.delete(golfHoleArray[0])
        }
        
        let newGame = GolfGame(context: context)
        newGame.dateStarted = Date()
        
        if section == 0 && index == 0 {
            newGame.courseName = "9 Hole Course"
            newGame.puttCount = [0,0,0,0,0,0,0,0,0]
            newGame.strokeCount = [0,0,0,0,0,0,0,0,0]
            newGame.totalCount = [0,0,0,0,0,0,0,0,0]
        }
        else if section == 0 && index == 1 {
            newGame.courseName = "18 Hole Course"
            newGame.puttCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            newGame.strokeCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            newGame.totalCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        } else {
            if courseArray[index].coursePar?.count == 9 {
                newGame.courseName = courseArray[index].courseName
                newGame.puttCount = [0,0,0,0,0,0,0,0,0]
                newGame.strokeCount = [0,0,0,0,0,0,0,0,0]
                newGame.totalCount = [0,0,0,0,0,0,0,0,0]
                newGame.parCount = courseArray[index].coursePar
            } else {
                newGame.courseName = courseArray[index].courseName
                newGame.puttCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                newGame.strokeCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                newGame.totalCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                newGame.parCount = courseArray[index].coursePar
            }
        }
        
        golfHoleArray = [newGame]
        save()
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
    
    func loadCourses() {
        
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        
        do {
            courseArray = try context.fetch(request)
            let sort = NSSortDescriptor(key: "courseName", ascending: true)
            request.sortDescriptors = [sort]
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
