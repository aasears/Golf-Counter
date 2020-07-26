//
//  NewGameInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class NewGameInterfaceController: WKInterfaceController {

    @IBOutlet var courseTable: WKInterfaceTable!
    
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    
    var courseArray = [Course]()
    //var courseParArray = [[Int]]()
    var golfGameArray = [GolfGame]()
    var orderCounter = 0
    var activeGame = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //courseArray = UserDefaults.standard.stringArray(forKey: "courses") ?? [""]
        //courseParArray = UserDefaults.standard.array(forKey: "coursePar") as? [[Int]] ?? [[]]
        
        loadData()
        loadCourses()
        loadNewGameFields()
    }

    override func willActivate() {
        super.willActivate()
        
        if checkForActiveGame() && UserDefaults.standard.bool(forKey: "continueGame") {
            UserDefaults.standard.set(false, forKey: "continueGame")
            presentController(withName: "GameController", context: nil)
        }
        
        if UserDefaults.standard.bool(forKey: "mainMenu") {
            UserDefaults.standard.set(false, forKey: "mainMenu")
            popToRootController()
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
        
    }
    
    func loadNewGameFields() {
        setTitle("New Game")
        
        var rowTypes = ["GenericGameRowController","GenericGameRowController"]
        for _ in 0..<courseArray.count {
            rowTypes.append("CourseGameRowController")
        }
        
//        if courseArray.count == 1 && courseArray[0] == "" {
//            rowTypes.remove(at: 2)
//        }
        
        courseTable.setRowTypes(rowTypes)
        
        var courseIndex = 0
        for index in 0..<courseTable.numberOfRows {
            
            switch rowTypes[index] {
            case "GenericGameRowController":
                if index == 0 {
                    let controller = courseTable.rowController(at: 0) as! GenericGameRowController
                    controller.course = "9 Hole Game"
                } else if index == 1 {
                    let controller = courseTable.rowController(at: 1) as! GenericGameRowController
                    controller.course = "18 Hole Game"
                }
            default:
                let controller = courseTable.rowController(at: index) as! CourseGameRowController
                controller.course = courseArray[courseIndex].courseName
                controller.count = courseArray[courseIndex].coursePar?.count
                courseIndex += 1
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        loadData()
        let nineHoleArray = [0,0,0,0,0,0,0,0,0]
        let eighteenHoleArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        if UserDefaults.standard.bool(forKey: "multiCourse") {
            
            var orderCounter = UserDefaults.standard.integer(forKey: "orderCounter")
            let multiGame = GolfGame(context: context)
            
            if rowIndex == 0 {
                multiGame.courseName = "9 Hole Game"
                multiGame.strokeCount = nineHoleArray
                multiGame.puttCount = nineHoleArray
                multiGame.parCount = nineHoleArray
                multiGame.holeComplete = nineHoleArray
                
            } else if rowIndex == 1 {
                multiGame.courseName = "18 Hole Game"
                multiGame.strokeCount = eighteenHoleArray
                multiGame.puttCount = eighteenHoleArray
                multiGame.parCount = eighteenHoleArray
                multiGame.holeComplete = eighteenHoleArray
                
            } else {
                multiGame.courseName = courseArray[rowIndex - 2].courseName
                multiGame.parCount = courseArray[rowIndex - 2].coursePar
                
                if courseArray[rowIndex - 2].coursePar?.count == 9 {
                    multiGame.strokeCount = nineHoleArray
                    multiGame.puttCount = nineHoleArray
                    multiGame.holeComplete = nineHoleArray
                    
                } else if courseArray[rowIndex - 2].coursePar?.count == 18 {
                    multiGame.strokeCount = eighteenHoleArray
                    multiGame.puttCount = eighteenHoleArray
                    multiGame.holeComplete = eighteenHoleArray
                }
            }
            orderCounter += 1
            multiGame.isActive = true
            multiGame.dateCreated = Date()
            multiGame.orderIdentifier = Int16(orderCounter)
            setNewGameDefaults(orderCount: orderCounter, courseIndex: orderCounter)
        } else {
    
            for game in golfGameArray {
                context.delete(game)
            }
            
            let newGame = GolfGame(context: context)
            
            if rowIndex == 0 {
                newGame.courseName = "9 Hole Game"
                newGame.strokeCount = nineHoleArray
                newGame.puttCount = nineHoleArray
                newGame.parCount = nineHoleArray
                newGame.netCount = nineHoleArray
                newGame.holeComplete = nineHoleArray
                
            } else if rowIndex == 1 {
                newGame.courseName = "18 Hole Game"
                newGame.strokeCount = eighteenHoleArray
                newGame.puttCount = eighteenHoleArray
                newGame.parCount = eighteenHoleArray
                newGame.netCount = eighteenHoleArray
                newGame.holeComplete = eighteenHoleArray
                
            } else {
                newGame.courseName = courseArray[rowIndex - 2].courseName
                newGame.parCount = courseArray[rowIndex - 2].coursePar
                
                if courseArray[rowIndex - 2].coursePar?.count == 9 {
                    newGame.strokeCount = nineHoleArray
                    newGame.puttCount = nineHoleArray
                    newGame.netCount = nineHoleArray
                    newGame.holeComplete = nineHoleArray
                    
                } else if courseArray[rowIndex - 2].coursePar?.count == 18 {
                    newGame.strokeCount = eighteenHoleArray
                    newGame.puttCount = eighteenHoleArray
                    newGame.netCount = eighteenHoleArray
                    newGame.holeComplete = eighteenHoleArray

                }
            }
            UserDefaults.standard.set(0, forKey: "net")
            UserDefaults.standard.set(false, forKey: "continueGame")
            
            newGame.orderIdentifier = 0
            newGame.isActive = true
            newGame.dateCreated = Date()
            setNewGameDefaults(orderCount: 0, courseIndex: 0)
        }
        save()
        presentController(withName: "GameController", context: nil)
    }
    
    func setNewGameDefaults(orderCount: Int, courseIndex: Int) {
        
        UserDefaults.standard.set(0, forKey: "currentHole")
        UserDefaults.standard.set(orderCounter, forKey: "orderCounter")
        UserDefaults.standard.set(courseIndex, forKey: "courseIndex")
        UserDefaults.standard.set(false, forKey: "multiCourse")
    }
    
    func checkForActiveGame() -> Bool {
        
        for game in golfGameArray {
            if game.isActive { activeGame = true }
        }
        return activeGame
    }
    
    // MARK: - CoreData functions
    
    func loadData() {
        
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
