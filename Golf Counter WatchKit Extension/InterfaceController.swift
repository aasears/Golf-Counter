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
    @IBOutlet var summaryCounterGroup: WKInterfaceGroup!
    @IBOutlet var parGroup: WKInterfaceGroup!
    @IBOutlet var parCountLabel: WKInterfaceLabel!
    @IBOutlet var spacerLabel: WKInterfaceLabel!
    @IBOutlet var netGroup: WKInterfaceGroup!
    @IBOutlet var netCountLabel: WKInterfaceLabel!
    
    // Summary Outlets
    @IBOutlet var summaryTable: WKInterfaceTable!
    
    // Finish Outlets
    @IBOutlet var nextCourseButton: WKInterfaceButton!
    @IBOutlet var finishGameButton: WKInterfaceButton!
    @IBOutlet var finishGroup: WKInterfaceGroup!
    
    // Hole Select Outlets
    @IBOutlet var holeSelectPicker: WKInterfacePicker!
    @IBOutlet var holeSelectGroup: WKInterfaceGroup!
    
    // Variables
    var courseName = ""
    var strokeCount = [Int]()
    var puttCount = [Int]()
    var parCount = [Int]()
    var index = 0
    var pickerIndex = 0
    var holeArray = [WKPickerItem]()
    
    // Connectivity
    let session = WCSession.default
    
    
    // MARK: - Default Functions
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        UserDefaults.standard.set(true, forKey: "mainMenu")
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
    
    // MARK: - Menu Item Methods
    
    @IBAction func mainMenuButton() {
        dismiss()
    }
    
    @IBAction func holeSelectMenuButton() {
        setTitle("Select Hole:")
        holeSelectPicker.setItems(holeArray)
        holeSelectPicker.setSelectedItemIndex(index)
        holeSelectPicker.focus()
        counterGroup.setHidden(true)
        summaryTable.setHidden(true)
        finishGroup.setHidden(true)
        holeSelectGroup.setHidden(false)
    }
    
    // MARK: - General Methods
    
    @IBAction func pickerAction(_ value: Int) {
        pickerIndex = value
    }
    
    @IBAction func goToHole() {
        index = pickerIndex
        loadInterfaceViews()
    }
    
    func calculateNet() -> Int {
        
        var totalPar = 0
        var totalStroke = 0
        for index in 0..<strokeCount.count {
            if strokeCount[index] != 0 {
                totalPar += parCount[index]
                totalStroke += strokeCount[index]
            }
        }
        return totalStroke - totalPar
    }
    
    func setNet() {
        let net = calculateNet()
        if net > 0 {
            netCountLabel.setText("+\(net)")
        } else {
            netCountLabel.setText("\(net)")
        }
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
    
//    func sendGameToPhone2(applicationContext: Dictionary<String,Any>) {
//        if session.isReachable == true {
//            do {
//                try session.updateApplicationContext(applicationContext)
//            } catch {
//                print("error sending to phone \(error)")
//            }
//            //self.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
//        }
//    }
    
    func sendGameToPhone(applicationContext: Dictionary<String,Any>) {
        if session.isReachable == true {
            session.transferUserInfo(applicationContext)
        }
    }
    
    // MARK: - Load Data Methods
    
    func loadData() {
        courseName = UserDefaults.standard.string(forKey: "course") ?? ""
        strokeCount = UserDefaults.standard.array(forKey: "strokes") as! [Int]
        puttCount = UserDefaults.standard.array(forKey: "putts") as! [Int]
        parCount = UserDefaults.standard.array(forKey: "par") as! [Int]
        index = UserDefaults.standard.integer(forKey: "currentHole")
        for hole in 1...strokeCount.count {
            let pickerItem = WKPickerItem.init()
            pickerItem.title = String(hole)
            holeArray.append(pickerItem)
        }
        let summaryPage = WKPickerItem.init()
        summaryPage.title = "Summary"
        let finishPage = WKPickerItem.init()
        finishPage.title = "Finish"
        holeArray.append(summaryPage)
        holeArray.append(finishPage)
    }
    
    func loadInterfaceViews() {
        if index < strokeCount.count {
            loadCounterFields()
            counterGroup.setHidden(false)
            summaryTable.setHidden(true)
            finishGroup.setHidden(true)
            holeSelectGroup.setHidden(true)
            
            if UserDefaults.standard.bool(forKey: "netSettingActive") {
                netGroup.setHidden(false)
                spacerLabel.setHidden(false)
                parGroup.setHorizontalAlignment(.left)
            } else {
                netGroup.setHidden(true)
                spacerLabel.setHidden(true)
                parGroup.setHorizontalAlignment(.center)
            }
            
            if WKInterfaceDevice.current().name.contains("40") {
                counterGroup.setContentInset(.init(top: 0, left: 0, bottom: 14, right: 0))
            } else if WKInterfaceDevice.current().name.contains("44") {
                counterGroup.setContentInset(.init(top: 0, left: 0, bottom: 20, right: 0))
            } else {
                counterGroup.setContentInset(.init(top: 0, left: 0, bottom: 0, right: 0))
            }
        } else if index == strokeCount.count {
            loadSummaryFields()
            counterGroup.setHidden(true)
            summaryTable.setHidden(false)
            finishGroup.setHidden(true)
            holeSelectGroup.setHidden(true)
        } else if index == strokeCount.count + 1 {
            counterGroup.setHidden(true)
            summaryTable.setHidden(true)
            finishGroup.setHidden(false)
            holeSelectGroup.setHidden(true)
        }
    }
    
    func loadCounterFields() {
        setTitle("Hole \(index + 1)")
        strokeCounter.setText("\(strokeCount[index])")
        puttCounter.setText("\(puttCount[index])")
        if parCount[index] == 0 {
            summaryCounterGroup.setHidden(true)
        } else {
            summaryCounterGroup.setHidden(false)
            parCountLabel.setText("\(parCount[index])")
            setNet()
        }
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
