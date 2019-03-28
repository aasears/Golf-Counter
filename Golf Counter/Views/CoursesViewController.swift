//
//  CoursesViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class CoursesViewController: UITableViewController {

    var courseArray = [Course]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCourses()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseTableViewCell", for: indexPath) as! courseTableViewCell
        
        cell.courseName.text = courseArray[indexPath.row].courseName
        cell.numberOfCourseHoles.text = "\(courseArray[indexPath.row].coursePar?.count ?? 0)"
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditCourse", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditCourse" {
            
            let destinationVC = segue.destination as! EditCourseTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.index = indexPath.row
            }
        }
        save()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.context.delete(self.courseArray[indexPath.row])
            self.courseArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
    
    // MARK: - Action functions
    
    @IBAction func addNewCourse(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Course", message: "", preferredStyle: .alert)
        
        let nineAction = UIAlertAction(title: "9 Hole", style: .default) { (action) in
            let newCourse = Course(context: self.context)
            newCourse.courseName = textField.text!
            newCourse.coursePar = [3,3,3,3,3,3,3,3,3]
            self.courseArray.append(newCourse)
            self.save()
        }
        
        let eighteenAction = UIAlertAction(title: "18 Hole", style: .default) { (action) in
            let newCourse = Course(context: self.context)
            newCourse.courseName = textField.text!
            newCourse.coursePar = [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]
            self.courseArray.append(newCourse)
            self.save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a Course Name"
            textField = alertTextField
        }
        
        alert.addAction(nineAction)
        alert.addAction(eighteenAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        save()
        navigationController?.popToRootViewController(animated: true)
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
