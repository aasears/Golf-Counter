//
//  EditCourseTableViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class EditCourseTableViewController: UITableViewController, editCourseHoleTableViewCellDelegate {

    var courseArray = [Course]()
    var courseHoles = [Int]()
    var index: Int = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCourses()
        setSingleCourse()
        navigationItem.title = courseArray[index].courseName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseHoles.count
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCourseHoleTableViewCell", for: indexPath) as! editCourseHoleTableViewCell
        cell.setHoleDetails(holeNum: indexPath.row + 1, par: courseHoles[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        
        return cell
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
    
    func setSingleCourse() {
        
        courseHoles = courseArray[index].coursePar ?? []
    }
    
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func increasePar(holeNumber: Int) {
        courseArray[index].coursePar?[holeNumber - 1] += 1
    }
    
    func decreasePar(holeNumber: Int) {
        if courseArray[index].coursePar?[holeNumber - 1] ?? 0 > 3 {
            courseArray[index].coursePar?[holeNumber - 1] -= 1
        }
    }

}
