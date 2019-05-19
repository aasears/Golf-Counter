//
//  MainMenuViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/23/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class MainMenuViewController: UIViewController, WCSessionDelegate {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let session = WCSession.default
    
    var golfHoleArray = [GolfGame]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveWatchData), name: NSNotification.Name(rawValue: "ReceivedWatchMessage"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func didReceiveWatchData(info: NSNotification) {
        print("hit on phone")
        dictionaryToGolfHoleObject(message: info.userInfo as? Dictionary<String,Any> ?? ["error" : "Error passing data"])
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func dictionaryToGolfHoleObject(message: Dictionary<String,Any>) {
        let passedInGame = GolfGame(context: context)
        passedInGame.initializeGolfGame()
        passedInGame.courseName = message["course"] as? String
        passedInGame.strokeCount = message["strokes"] as? [Int]
        passedInGame.puttCount = message["putts"] as? [Int]
        passedInGame.parCount = message["par"] as? [Int]
        passedInGame.dateCreated = message["dateCreated"] as? Date
        passedInGame.dateCompleted = message["dateCompleted"] as? Date ?? nil
        passedInGame.isActive = message["isActive"] as? Bool ?? true
        passedInGame.orderIdentifier = message["orderIdentifier"] as? Int16 ?? 0
        
        if passedInGame.isActive == false {
            let finalGame = PastGolfGame(context: context)
            finalGame.dateFinished = passedInGame.dateCompleted
            
            //        if golfHoleArray.count > 1 {
            //            finalGame.title = "\(golfHoleArray[0].courseName ?? "") (\(golfHoleArray.count))"
            //        } else {
            finalGame.title = passedInGame.courseName
            passedInGame.history = finalGame
        }
        save()
    }
    
    @IBAction func continueGame(_ sender: UIButton) {
        
        loadData()
        
        if golfHoleArray.count == 0 {
            performSegue(withIdentifier: "goToSelectCourse", sender: self)
        } else {
            performSegue(withIdentifier: "goToContinueGame", sender: self)
        }
    }
    
    // MARK: - CoreData functions
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        let activePredicate = NSPredicate(format: "isActive == true")
        request.predicate = activePredicate
        let sort = NSSortDescriptor(key: "orderIdentifier", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            golfHoleArray = try context.fetch(request)
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
