//
//  MultipleCourseInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 1/12/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class MultipleCourseInterfaceController: WKInterfaceController {

    @IBOutlet var multipleCourseTable: WKInterfaceTable!
    @IBOutlet weak var addCourse: WKInterfaceButton!
    
    // Connectivity
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    
    // Variables
    var golfGameArray = [GolfGame]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        loadCoreData()
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
    
    
    @IBAction func addCourseButton() {
        
        UserDefaults.standard.set(true, forKey: "multiCourse")
        UserDefaults.standard.set("startMultiCourse", forKey: "navigationState")
        dismiss()
    }
        
    // MARK: - Standard table Methods
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        UserDefaults.standard.set(golfGameArray[rowIndex].orderIdentifier, forKey: "courseIndex")
        UserDefaults.standard.set(0, forKey: "index")
        UserDefaults.standard.set(true, forKey: "startGame")
        UserDefaults.standard.set(false, forKey: "multiGame")
            
        dismiss()
    }
    
    // MARK: - Load Data Methods
    
    func loadCourseFields() {
        setTitle("Select a Course")
        
        var rowTypes = [String]()
        for _ in golfGameArray {
            rowTypes.append("MultipleCourseRowController")
        }
        
        multipleCourseTable.setRowTypes(rowTypes)
        
        for index in 0..<multipleCourseTable.numberOfRows {
            let controller = multipleCourseTable.rowController(at: index) as? MultipleCourseRowController
            controller?.course = golfGameArray[index].courseName
            controller?.count = golfGameArray[index].parCount?.count
            controller?.order = Int(golfGameArray[index].orderIdentifier) + 1
        }
    }
    
    // MARK: - CoreData functions
    
    func loadCoreData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        let activePredicate = NSPredicate(format: "isActive == true")
        request.predicate = activePredicate
        let sort = NSSortDescriptor(key: "orderIdentifier", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            golfGameArray = try context.fetch(request)
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

