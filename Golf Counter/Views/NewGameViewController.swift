//
//  NewGameViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/31/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class NewGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var selectMultipleButton: UIButton!
    @IBOutlet weak var courseSelectionTableView: UITableView!
    @IBOutlet var courseStartView: UIView!
    
    
    let sections = ["Standard Game", "Courses"]
    let standardGameOptions = ["9 Holes", "18 Holes"]
    
    var allowMultipleSelection = false
    var countSelected = 0
    
    var courseArray = [Course]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCourses()
        courseSelectionTableView.delegate = self
        courseSelectionTableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
        case 0:
            return standardGameOptions.count
        default:
            return courseArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newGameCourseTableViewCell", for: indexPath) as! newGameCourseTableViewCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if allowMultipleSelection {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.selectionStyle = .none
                cell.accessoryType = .checkmark
                if countSelected == 0 {
                    selectMultipleButton.setTitle("Let's Play", for: .normal)
                }
                countSelected += 1
            }
        } else {
            performSegue(withIdentifier: "goToNewGame", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            countSelected -= 1
            if countSelected == 0 {
                selectMultipleButton.setTitle("Cancel", for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNewGame" {
            
            let destinationVC = segue.destination as! GolfHoleViewController
            
            if let indexPath = courseSelectionTableView.indexPathForSelectedRow {
                
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
    
    @IBAction func selectMultipleButtonPressed(_ sender: UIButton) {
        
        if countSelected == 1 {
            performSegue(withIdentifier: "goToNewGame", sender: self)
        } else if countSelected > 1 {
            self.view.addSubview(courseStartView)
            courseStartView.center = self.view.center
            courseStartView.layer.cornerRadius = 40
            //courseStartView.popoverLayoutMargins = UIEdgeInsets(top: 10)
        } else if !allowMultipleSelection {
            allowMultipleSelection = true
            courseSelectionTableView.allowsMultipleSelection = true
            selectMultipleButton.setTitle("Cancel", for: .normal)
        } else {
            allowMultipleSelection = false
            selectMultipleButton.setTitle("Select Multiple Courses", for: .normal)
        }
    }
    
    @IBAction func courseStartBackButton(_ sender: UIButton) {
        self.courseStartView.removeFromSuperview()
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
        
        courseSelectionTableView.reloadData()
    }
    
}
