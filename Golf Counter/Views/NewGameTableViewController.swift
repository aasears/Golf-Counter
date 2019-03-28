//
//  NewGameTableViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class NewGameTableViewController: UITableViewController {

    let sections = ["Standard Game", "Courses"]
    let standardGameOptions = ["9 Holes", "18 Holes"]
    
    var courseArray = [Course]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCourses()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
            case 0:
                return standardGameOptions.count
            default:
                return courseArray.count
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newGameCourseTableViewCell", for: indexPath) as! courseTableViewCell
        if indexPath.section == 0 {
            cell.courseName.text = standardGameOptions[indexPath.row]
            cell.numberOfCourseHoles.isHidden = true
            cell.holeLabel.isHidden = true
        } else {
            cell.courseName.text = courseArray[indexPath.row].courseName
            cell.numberOfCourseHoles.text = "\(courseArray[indexPath.row].coursePar?.count ?? 0)"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNewGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNewGame" {
            
            let destinationVC = segue.destination as! GolfHoleViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                if indexPath.section == 0 {
                    destinationVC.section = indexPath.section
                    destinationVC.index = indexPath.row
                } else {
                    destinationVC.section = indexPath.section
                    destinationVC.index = indexPath.row
                    destinationVC.continueGame = false
                }
            }
        }
    }


    // MARK: - CoreData functions
    
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
        
        tableView.reloadData()
    }

}
