//
//  NewGameInterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 6/22/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation


class NewGameInterfaceController: WKInterfaceController {

    @IBOutlet var courseTable: WKInterfaceTable!
    
    var courseArray = [String]()
    var courseParArray = [[Int]]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        courseArray = UserDefaults.standard.stringArray(forKey: "courses") ?? [""]
        courseParArray = UserDefaults.standard.array(forKey: "coursePar") as? [[Int]] ?? [[]]
        
        loadNewGameFields()
    }

    override func willActivate() {
        super.willActivate()
        
        if UserDefaults.standard.bool(forKey: "activeGame") && UserDefaults.standard.bool(forKey: "continueGame") {
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
        
        if courseArray.count == 1 && courseArray[0] == "" {
            rowTypes.remove(at: 2)
        }
        
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
                controller.course = courseArray[courseIndex]
                controller.count = courseParArray[courseIndex].count
                courseIndex += 1
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let nineHoleArray = [0,0,0,0,0,0,0,0,0]
        let eighteenHoleArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        if rowIndex == 0 {
            UserDefaults.standard.set("9 Hole Game", forKey: "course")
            UserDefaults.standard.set(nineHoleArray, forKey: "strokes")
            UserDefaults.standard.set(nineHoleArray, forKey: "putts")
            UserDefaults.standard.set(nineHoleArray, forKey: "par")
        } else if rowIndex == 1 {
            UserDefaults.standard.set("18 Hole Game", forKey: "course")
            UserDefaults.standard.set(eighteenHoleArray, forKey: "strokes")
            UserDefaults.standard.set(eighteenHoleArray, forKey: "putts")
            UserDefaults.standard.set(eighteenHoleArray, forKey: "par")
        } else {
            
            UserDefaults.standard.set(courseArray[rowIndex - 2], forKey: "course")
            UserDefaults.standard.set(courseParArray[rowIndex - 2], forKey: "par")
            
            if courseParArray[rowIndex - 2].count == 9 {
                UserDefaults.standard.set(nineHoleArray, forKey: "strokes")
                UserDefaults.standard.set(nineHoleArray, forKey: "putts")
            } else if courseParArray[rowIndex - 2].count == 18 {
                UserDefaults.standard.set(eighteenHoleArray, forKey: "strokes")
                UserDefaults.standard.set(eighteenHoleArray, forKey: "putts")
            }
        }
        UserDefaults.standard.set(0, forKey: "currentHole")
        UserDefaults.standard.set(true, forKey: "activeGame")
        UserDefaults.standard.set(false, forKey: "continueGame")
        UserDefaults.standard.set(Date(), forKey: "dateCreated")
        presentController(withName: "GameController", context: nil)
    }

}
