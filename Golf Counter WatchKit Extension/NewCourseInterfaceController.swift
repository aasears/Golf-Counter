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
import WatchConnectivity


class contextForPar: NSObject {
    var parValue = 0
    var delegate: AnyObject? = nil
}

protocol EditCourseDelegate {
    func saveEditedCourse(editedCourse: Course)
}

class NewCourseInterfaceController: WKInterfaceController, ParUpdateDelegate {

    @IBOutlet weak var parTable: WKInterfaceTable!
    @IBOutlet weak var courseName: WKInterfaceTextField!
    
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    let session = WCSession.default
    
    var delegate: CourseInterfaceController? = nil
    
    var newCourseName = ""
    var parArray = [3,3,3,3,3,3,3,3,3]
    var holeIndex = 0
    var editCourse = Course()
    var editFlag = false
      
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let passedContext = context as? contextForEditedCourse
        
        delegate = passedContext?.delegate as? CourseInterfaceController
        
        if let course: Course = passedContext?.course {
            editCourse = course
            parArray  = editCourse.coursePar ?? []
            courseName.setText(editCourse.courseName)
            editFlag = true
        }
      
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
    
    // MARK: - Segue Methods
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        holeIndex = rowIndex
        let parContext = contextForPar()
        parContext.parValue = parArray[rowIndex]
        parContext.delegate = self
        return parContext
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        presentController(withName: "goToUpdatePar", context: self)
    }
    
    // MARK: - Protocol Methods
    
    func didUpdateParValue(newParValue: Int) {
        parArray[holeIndex] = newParValue
        loadCourseFields()
    }
    
    
    // MARK: - Menu Item Methods
    
    @IBAction func getCourseName(_ value: NSString?) {
        if value != nil {
            newCourseName = value! as String
        }
    }
    
    @IBAction func saveCourseButton() {
        if editFlag {
            if newCourseName != "" {
                editCourse.courseName = newCourseName
            }
            editCourse.coursePar = parArray
            delegate?.saveEditedCourse(editedCourse: editCourse)
            self.session.transferUserInfo(["messageType" : "Course",
                                           "addCourse" : false,
                                           "updateCourse" : true,
                                           "deleteCourse" : false,
                                           "dateCreated" : editCourse.dateCreated as Any,
                                           "title" : editCourse.courseName as Any,
                                           "par" : editCourse.coursePar as Any])
            pop()
            
        }
        else if newCourseName != "" {
            let newCourse = Course(context: context)
            newCourse.courseName = newCourseName
            newCourse.coursePar = parArray
            newCourse.dateCreated = Date()
            save()
            self.session.transferUserInfo(["messageType" : "Course",
                                           "addCourse" : true,
                                           "updateCourse" : false,
                                           "deleteCourse" : false,
                                           "dateCreated" : newCourse.dateCreated as Any,
                                           "title" : newCourse.courseName as Any,
                                           "par" : newCourse.coursePar as Any])
            pop()
        }
    }
    
    @IBAction func addNineHolesButton() {
        parArray.append(contentsOf: [3,3,3,3,3,3,3,3,3])
        loadCourseFields()
    }
    
    // MARK: - Load Data Methods
    
    func loadCourseFields() {
        setTitle("Add Course")
        
        courseName.setPlaceholder("Enter Name")
        
        var rowTypes = [String]()
        for _ in 0..<parArray.count {
            rowTypes.append("CourseParRowController")
        }
        
        parTable.setRowTypes(rowTypes)
        
        for index in 0..<parTable.numberOfRows {
            let controller = parTable.rowController(at: index) as! CourseParRowController
            controller.par = parArray[index]
            controller.hole = index + 1
        }
    }
    
    // MARK: - CoreData Methods
      
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }

}
