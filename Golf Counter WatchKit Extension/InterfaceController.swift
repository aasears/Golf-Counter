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
import CoreData

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
    var golfGameArray = [GolfGame]()
    var netCount = 0
    var index = 0
    var courseIndex = 0
    var pickerIndex = 0
    var holeArray = [WKPickerItem]()
    
    // Connectivity
    let session = WCSession.default
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext

    
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
        
        UserDefaults.standard.set(index, forKey: "currentHole")
        UserDefaults.standard.set(netCount, forKey: "net")
        save()
    }
    
    // MARK: - Count Functions
    
    @IBAction func plusStrokeButtonPressed() {
        if (golfGameArray[courseIndex].strokeCount?[index] ?? 0) < 99 {
            golfGameArray[courseIndex].strokeCount?[index] += 1
            strokeCounter.setText("\(golfGameArray[courseIndex].strokeCount?[index] ?? 0)")
        }
    }
    
    @IBAction func minusStrokeButtonPressed() {
        if (golfGameArray[courseIndex].strokeCount?[index] ?? 0) > 0 &&
            (golfGameArray[courseIndex].strokeCount?[index] ?? 0) > (golfGameArray[courseIndex].puttCount?[index] ?? 0) {
            golfGameArray[courseIndex].strokeCount?[index] -= 1
            strokeCounter.setText("\(golfGameArray[courseIndex].strokeCount?[index] ?? 0)")
        }
    }
    
    @IBAction func plusPuttButtonPressed() {
        if (golfGameArray[courseIndex].strokeCount?[index] ?? 0) < 99 {
            golfGameArray[courseIndex].puttCount?[index] += 1
            golfGameArray[courseIndex].strokeCount?[index] += 1
            puttCounter.setText("\(golfGameArray[courseIndex].puttCount?[index] ?? 0)")
            strokeCounter.setText("\(golfGameArray[courseIndex].strokeCount?[index] ?? 0)")
        }
    }
    
    @IBAction func minusPuttButtonPressed() {
        if (golfGameArray[courseIndex].strokeCount?[index] ?? 0) > 0 &&
            (golfGameArray[courseIndex].puttCount?[index] ?? 0) > 0 {
            golfGameArray[courseIndex].puttCount?[index] -= 1
            golfGameArray[courseIndex].strokeCount?[index] -= 1
            puttCounter.setText("\(golfGameArray[courseIndex].puttCount?[index] ?? 0)")
            strokeCounter.setText("\(golfGameArray[courseIndex].strokeCount?[index] ?? 0)")
        }
    }
    
    // MARK: - Finish Game Methods
    
    @IBAction func nextCourseButtonPressed() {
        UserDefaults.standard.set("selectMultiCourse", forKey: "navigationState")
        UserDefaults.standard.set(0, forKey: "currentHole")
        UserDefaults.standard.set(true, forKey: "selectActiveCourseFl")
        dismiss()
    }
    
    @IBAction func finishGameButtonPressed() {
        UserDefaults.standard.set(false, forKey: "activeGame")
        UserDefaults.standard.set(false, forKey: "multiCourse")
        UserDefaults.standard.set(0, forKey: "courseIndex")
        save()
        let dict = parseFinishedDefaultsFromWatch()
        sendGameToPhone(applicationContext: dict)
        dismiss()
        
        // Add a finish later button
    }
    
    // MARK: - Gesture Methods
    
    @IBAction func leftSwipe(_ sender: Any) {
        
        if index <= (golfGameArray[courseIndex].strokeCount?.count ?? 0) {
            if index < golfGameArray[courseIndex].holeComplete?.count ?? 0 {
                golfGameArray[courseIndex].holeComplete?[index] = 1
            }
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
        if let holeCount = golfGameArray[courseIndex].strokeCount?.count {
            for index in 0..<holeCount {
                if golfGameArray[courseIndex].strokeCount?[index] != 0 && golfGameArray[courseIndex].holeComplete?[index] != 0 {
                    totalPar += golfGameArray[courseIndex].parCount?[index] ?? 0
                    totalStroke += golfGameArray[courseIndex].strokeCount?[index] ?? 0
                }
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
    
//    func parseDefaultsFromWatch() -> Dictionary<String,Any> {
//
//        let dictionaryGame = [
//            "strokes" : UserDefaults.standard.array(forKey: "strokes") as Any,
//            "putts" : UserDefaults.standard.array(forKey: "putts") as Any,
//            "par" : UserDefaults.standard.array(forKey: "par") as Any,
//            "course" : UserDefaults.standard.string(forKey: "course") as Any,
//            "dateCreated" : UserDefaults.standard.object(forKey: "dateCreated") as Any,
//            "isActive" : true as Any,
//            "orderIdentifier" : UserDefaults.standard.integer(forKey: "orderIdentifier") as Any]
//        return dictionaryGame
//    }

    func parseFinishedDefaultsFromWatch() -> Dictionary<String,Any> {
        
        let dictionaryGame = [
            "messageType" : "Finished Game",
            "strokes" : golfGameArray[courseIndex].strokeCount as Any,
            "putts" : golfGameArray[courseIndex].puttCount as Any,
            "par" : golfGameArray[courseIndex].parCount as Any,
            "course" : golfGameArray[courseIndex].courseName as Any,
            "dateCreated" : golfGameArray[courseIndex].dateCreated as Any,
            "dateCompleted" : Date() as Any,
            "isActive" : false as Any,
            "orderIdentifier" : golfGameArray[courseIndex].orderIdentifier as Any]
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
        loadCoreData()
        netCount = UserDefaults.standard.integer(forKey: "net")
        index = UserDefaults.standard.integer(forKey: "currentHole")
        courseIndex = UserDefaults.standard.integer(forKey: "courseIndex")
        
        if let holeCount = golfGameArray[courseIndex].strokeCount?.count {
            for hole in 1...holeCount {
                let pickerItem = WKPickerItem.init()
                pickerItem.title = String(hole)
                holeArray.append(pickerItem)
            }
        }
        let summaryPage = WKPickerItem.init()
        summaryPage.title = "Summary"
        let finishPage = WKPickerItem.init()
        finishPage.title = "Finish"
        holeArray.append(summaryPage)
        holeArray.append(finishPage)
    }
    
    func loadInterfaceViews() {
        if index < (golfGameArray[courseIndex].strokeCount?.count ?? 0) {
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
        } else if index == golfGameArray[courseIndex].strokeCount?.count {
            loadSummaryFields()
            counterGroup.setHidden(true)
            summaryTable.setHidden(false)
            finishGroup.setHidden(true)
            holeSelectGroup.setHidden(true)
        } else if index == (golfGameArray[courseIndex].strokeCount?.count ?? 0) + 1 {
            counterGroup.setHidden(true)
            summaryTable.setHidden(true)
            finishGroup.setHidden(false)
            holeSelectGroup.setHidden(true)
        }
    }
    
    func loadCounterFields() {
        setTitle("Hole \(index + 1)")
        strokeCounter.setText("\(golfGameArray[courseIndex].strokeCount?[index] ?? 0)")
        puttCounter.setText("\(golfGameArray[courseIndex].puttCount?[index] ?? 0)")
        if golfGameArray[courseIndex].parCount?[index] == 0 {
            summaryCounterGroup.setHidden(true)
        } else {
            summaryCounterGroup.setHidden(false)
            parCountLabel.setText("\(golfGameArray[courseIndex].parCount?[index] ?? 0)")
            setNet()
        }
    }
    
    func loadSummaryFields() {
        setTitle(golfGameArray[courseIndex].courseName)
        
        var rowTypes = ["HeaderRowController","HeaderRowController"]
        var strokeSum = 0
        var parSum = 0
        if let holeCount = golfGameArray[courseIndex].strokeCount?.count {
            for hole in 0..<holeCount {
                rowTypes.append("SummaryRowController")
                strokeSum += golfGameArray[courseIndex].strokeCount?[hole] ?? 0
                parSum += golfGameArray[courseIndex].parCount?[hole] ?? 0
            }
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
                controller.strokes = golfGameArray[courseIndex].strokeCount?[holeIndex]
                holeIndex += 1
            }
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
