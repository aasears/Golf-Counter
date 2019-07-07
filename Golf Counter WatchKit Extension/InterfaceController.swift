//
//  InterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    // Counter Outlets
    @IBOutlet var strokeCounter: WKInterfaceLabel!
    @IBOutlet var puttCounter: WKInterfaceLabel!
    @IBOutlet var counterGroup: WKInterfaceGroup!
    
    // Summary Outlets
    @IBOutlet var summaryTable: WKInterfaceTable!
    @IBOutlet var totalCountLabel: WKInterfaceLabel!
    @IBOutlet var parCountLabel: WKInterfaceLabel!
    @IBOutlet var parGroup: WKInterfaceGroup!
    
    // Finish Outlets
    @IBOutlet var nextCourseButton: WKInterfaceButton!
    @IBOutlet var finishGameButton: WKInterfaceButton!
    @IBOutlet var finishGroup: WKInterfaceGroup!
    
    var courseName = ""
    var strokeCount = [Int]()
    var puttCount = [Int]()
    var parCount = [Int]()
    var index = 0
    
    let session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        loadData()
    }
    
    override func willActivate() {
        super.willActivate()
        
        loadInterfaceViews()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        UserDefaults.standard.set(strokeCount, forKey: "strokes")
        UserDefaults.standard.set(puttCount, forKey: "putts")
        UserDefaults.standard.set(index, forKey: "currentHole")
    }
    
    // MARK: - Count Functions
    
    @IBAction func plusStrokeButtonPressed() {
        if strokeCount[index] < 99 {
            strokeCount[index] += 1
            strokeCounter.setText("\(strokeCount[index])")
        }
    }
    
    @IBAction func minusStrokeButtonPressed() {
        if strokeCount[index] > 0 && strokeCount[index] > puttCount[index] {
            strokeCount[index] -= 1
            strokeCounter.setText("\(strokeCount[index])")
        }
    }
    
    @IBAction func plusPuttButtonPressed() {
        if strokeCount[index] < 99 {
            puttCount[index] += 1
            strokeCount[index] += 1
            puttCounter.setText("\(puttCount[index])")
            strokeCounter.setText("\(strokeCount[index])")
        }
    }
    
    @IBAction func minusPuttButtonPressed() {
        if strokeCount[index] > 0 && puttCount[index] > 0 {
            puttCount[index] -= 1
            strokeCount[index] -= 1
            puttCounter.setText("\(puttCount[index])")
            strokeCounter.setText("\(strokeCount[index])")
        }
    }
    
    // MARK: - Finish Game Methods
    
    @IBAction func nextCourseButtonPressed() {
    }
    
    @IBAction func finishGameButtonPressed() {
        
        UserDefaults.standard.set(strokeCount, forKey: "strokes")
        UserDefaults.standard.set(puttCount, forKey: "putts")
        UserDefaults.standard.set(false, forKey: "activeGame")
        let dict = parseFinishedDefaultsFromWatch()
        sendGameToPhone(applicationContext: dict)
        
        dismiss()
        
        // Add a finish later button
    }
    
    // MARK: - Gesture Methods
    
    @IBAction func leftSwipe(_ sender: Any) {
        
        if index <= strokeCount.count {
            index += 1
        }
        
        loadInterfaceViews()
        UserDefaults.standard.set(index, forKey: "currentHole")
    }
    
    @IBAction func rightSwipe(_ sender: Any) {
        
        if index > 0 {
            index -= 1
        }
        
        loadInterfaceViews()
        UserDefaults.standard.set(index, forKey: "currentHole")
    }
    
    // MARK: - Connectivity Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func parseDefaultsFromWatch() -> Dictionary<String,Any> {
        
        let dictionaryGame = [
            "strokes" : UserDefaults.standard.array(forKey: "strokes") as Any,
            "putts" : UserDefaults.standard.array(forKey: "putts") as Any,
            "par" : UserDefaults.standard.array(forKey: "par") as Any,
            "course" : UserDefaults.standard.string(forKey: "course") as Any,
            "dateCreated" : UserDefaults.standard.object(forKey: "dateCreated") as Any,
            "isActive" : true as Any,
            "orderIdentifier" : UserDefaults.standard.integer(forKey: "orderIdentifier") as Any]
        return dictionaryGame
    }

    func parseFinishedDefaultsFromWatch() -> Dictionary<String,Any> {
        
        let dictionaryGame = [
            "strokes" : UserDefaults.standard.array(forKey: "strokes") as Any,
            "putts" : UserDefaults.standard.array(forKey: "putts") as Any,
            "par" : UserDefaults.standard.array(forKey: "par") as Any,
            "course" : UserDefaults.standard.string(forKey: "course") as Any,
            "dateCreated" : UserDefaults.standard.object(forKey: "dateCreated") as Any,
            "dateCompleted" : Date() as Any,
            "isActive" : false as Any,
            "orderIdentifier" : UserDefaults.standard.integer(forKey: "orderIdentifier") as Any]
        return dictionaryGame
    }
    
    func sendGameToPhone(applicationContext: Dictionary<String,Any>) {
        if session.isReachable == true {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch {
                print("error sending to phone \(error)")
            }
            //self.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    // MARK: - Load Data Methods
    
    func loadData() {
        courseName = UserDefaults.standard.string(forKey: "course") ?? ""
        strokeCount = UserDefaults.standard.array(forKey: "strokes") as! [Int]
        puttCount = UserDefaults.standard.array(forKey: "putts") as! [Int]
        parCount = UserDefaults.standard.array(forKey: "par") as! [Int]
        index = UserDefaults.standard.integer(forKey: "currentHole")
    }
    
    func loadInterfaceViews() {
        if index < strokeCount.count {
            loadCounterFields()
            counterGroup.setHidden(false)
            summaryTable.setHidden(true)
            finishGroup.setHidden(true)
        } else if index == strokeCount.count {
            loadSummaryFields()
            counterGroup.setHidden(true)
            summaryTable.setHidden(false)
            finishGroup.setHidden(true)
        } else if index == strokeCount.count + 1 {
            counterGroup.setHidden(true)
            summaryTable.setHidden(true)
            finishGroup.setHidden(false)
        }
    }
    
    func loadCounterFields() {
        setTitle("Hole \(index + 1)")
        strokeCounter.setText("\(strokeCount[index])")
        puttCounter.setText("\(puttCount[index])")
    }
    
    func loadSummaryFields() {
        setTitle(courseName)
        
        var rowTypes = ["HeaderRowController","HeaderRowController"]
        var strokeSum = 0
        var parSum = 0
        for hole in 0..<strokeCount.count {
            rowTypes.append("SummaryRowController")
            strokeSum += strokeCount[hole]
            parSum += parCount[hole]
        }
        
        if parSum == 0 {
            rowTypes.remove(at: 1)
        }
        summaryTable.setRowTypes(rowTypes)
        
        var holeIndex = 0
        for index in 0..<summaryTable.numberOfRows {
            
            switch rowTypes[index] {
            case "HeaderRowController":
                if index == 0 {
                    let controller = summaryTable.rowController(at: 0) as! HeaderRowController
                    controller.title = "Total"
                    controller.count = strokeSum
                } else if index == 1 {
                    let controller = summaryTable.rowController(at: 1) as! HeaderRowController
                    controller.title = "Par"
                    controller.count = parSum
                }
            default:
                let controller = summaryTable.rowController(at: index) as! SummaryRowController
                controller.hole = holeIndex + 1
                controller.strokes = strokeCount[holeIndex]
                holeIndex += 1
            }
        }
    }
    


}
