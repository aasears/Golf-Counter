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
    @IBOutlet var summaryGroup: WKInterfaceGroup!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePhoneData), name: NSNotification.Name(rawValue: "receivedPhoneData"), object: nil)
        
        loadData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        loadFields()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        UserDefaults.standard.set(strokeCount, forKey: "strokes")
        UserDefaults.standard.set(puttCount, forKey: "putts")
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
        let dict = parseFinishedDefaultsFromWatch()
        sendGameToPhone(message: dict)
        
        dismiss()
        
        // Add a finish later button
    }
    
    // MARK: - Gesture Methods
    
    @IBAction func leftSwipe(_ sender: Any) {
        
        if index < strokeCount.count - 1 {
            index += 1
            loadFields()
        } else if index == strokeCount.count - 1 {
            index += 1
            loadSummaryFields()
            counterGroup.setHidden(true)
            summaryGroup.setHidden(false)
            finishGroup.setHidden(true)
        } else if index == strokeCount.count {
            index += 1
            counterGroup.setHidden(true)
            summaryGroup.setHidden(true)
            finishGroup.setHidden(false)
        }
    }
    
    @IBAction func rightSwipe(_ sender: Any) {
        
        if index > 0 && index < strokeCount.count {
            index -= 1
            loadFields()
        } else if index == strokeCount.count {
            index -= 1
            loadFields()
            counterGroup.setHidden(false)
            summaryGroup.setHidden(true)
            finishGroup.setHidden(true)
        } else if index == strokeCount.count + 1 {
            index -= 1
            loadSummaryFields()
            counterGroup.setHidden(true)
            summaryGroup.setHidden(false)
            finishGroup.setHidden(true)
        }
    }
    
    // MARK: - Connectivity Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    @objc func didReceivePhoneData(info: NSNotification) {
        parseDictionaryFromPhone(message: info.userInfo as? Dictionary<String, Any> ?? ["" : "Error"])
        loadData()
        loadFields()
    }
    
    func parseDictionaryFromPhone(message: Dictionary<String,Any>) {
        UserDefaults.standard.set(message["course"], forKey: "course")
        UserDefaults.standard.set(message["strokes"], forKey: "strokes")
        UserDefaults.standard.set(message["putts"], forKey: "putts")
        UserDefaults.standard.set(message["par"], forKey: "par")
        UserDefaults.standard.set(message["dateCreated"], forKey: "dateCreated")
        UserDefaults.standard.set(message["orderIdentifier"], forKey: "orderIdentifier")
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
    
    func sendGameToPhone(message: Dictionary<String,Any>) {
        if self.session.isReachable == true {
            do {
                try self.session.updateApplicationContext(message)
            } catch {
                print("error saving context \(error)")
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
    }
    
    func loadFields() {
        setTitle("Hole \(index + 1)")
        strokeCounter.setText("\(strokeCount[index])")
        puttCounter.setText("\(puttCount[index])")
    }
    
    func loadSummaryFields() {
        setTitle(courseName)
        summaryTable.setNumberOfRows(strokeCount.count, withRowType: "SummaryRow")
        for row in 0..<summaryTable.numberOfRows {
            guard let controller = summaryTable.rowController(at: row) as? SummaryRowController else {continue}
            
            controller.hole = row + 1
            controller.strokes = strokeCount[row]
        }
        
        var totalCount = 0
        var parTotalCount = 0
        for hole in strokeCount {
            totalCount += hole
        }
        totalCountLabel.setText("\(totalCount)")
        
        if parCount[0] > 0 {
            for hole in parCount {
                parTotalCount += hole
            }
            parCountLabel.setText("\(parTotalCount)")
            parGroup.setHidden(false)
        } else {
            parGroup.setHidden(true)
        }
    }

}
