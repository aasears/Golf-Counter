//
//  CourseInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData


class CourseInterfaceController: WKInterfaceController {

    @IBOutlet var courseTable: WKInterfaceTable!
    
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    var courseArray = [Course]()
    
    //var courseArray1 = [String]()
    //var courseParArray = [[Int]]()
    //var courseDateCreatedArray = [Date]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //courseArray1 = UserDefaults.standard.stringArray(forKey: "courses") ?? []
        //courseParArray = UserDefaults.standard.array(forKey: "coursePar") as? [[Int]] ?? []
        //courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as? [Date] ?? []
        
        loadCourses()
        loadCourseFields()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Menu Item Methods
    
    @IBAction func mainMenuButton() {
        popToRootController()
    }
    
    @IBAction func addCourseMenuButton() {
    }
    
    // MARK: - Load Data Methods
    
    func loadCourseFields() {
        setTitle("Courses")
        
        var rowTypes = [String]()
        //for _ in 0..<courseArray1.count {
        for _ in 0..<courseArray.count {
            rowTypes.append("CourseGameRowController")
        }
        
        courseTable.setRowTypes(rowTypes)
        
        for index in 0..<courseTable.numberOfRows {
            let controller = courseTable.rowController(at: index) as! CourseGameRowController
            //controller.course = courseArray1[index]
            //controller.count = courseParArray[index].count
            controller.course = courseArray[index].courseName
            controller.count = courseArray[index].coursePar?.count
        }
    }
    
    // MARK: - Core Data Methods
    
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
