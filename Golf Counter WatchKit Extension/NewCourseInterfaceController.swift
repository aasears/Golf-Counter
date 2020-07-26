//
//  NewCourseInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 7/25/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData


class NewCourseInterfaceController: WKInterfaceController {

    @IBOutlet weak var parTable: WKInterfaceTable!
    @IBOutlet weak var courseName: WKInterfaceTextField!
    
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext

    
    var courseArray = [String]()
    var courseParArray = [[Int]]()
    var courseDateCreatedArray = [Date]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        courseArray = UserDefaults.standard.stringArray(forKey: "courses") ?? []
        courseParArray = UserDefaults.standard.array(forKey: "coursePar") as? [[Int]] ?? []
        courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as? [Date] ?? []
        
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
        setTitle("Add Course")
        
        var rowTypes = [String]()
        for _ in 0..<courseArray.count {
            rowTypes.append("CourseParRowController")
        }
        
        parTable.setRowTypes(rowTypes)
        
        for index in 0..<parTable.numberOfRows {
            let controller = parTable.rowController(at: index) as! CourseParRowController
            controller.par = courseArray[index]
            controller.count = courseParArray[index].count
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
