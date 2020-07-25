//
//  CourseInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation


class CourseInterfaceController: WKInterfaceController {

    @IBOutlet var courseTable: WKInterfaceTable!
    
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
        setTitle("Courses")
        
        var rowTypes = [String]()
        for _ in 0..<courseArray.count {
            rowTypes.append("CourseGameRowController")
        }
        
        courseTable.setRowTypes(rowTypes)
        
        for index in 0..<courseTable.numberOfRows {
            let controller = courseTable.rowController(at: index) as! CourseGameRowController
            controller.course = courseArray[index]
            controller.count = courseParArray[index].count
        }
    }

}
