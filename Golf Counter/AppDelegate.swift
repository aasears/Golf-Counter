//
//  AppDelegate.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //print("Documents Directory: ", persistentContainer.persistentStoreCoordinator.persistentStores.last?.url ?? "Not Found!")
        
        //WatchSessionManager.sharedManager.startSession()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

        self.saveContext()
        
    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedWatchMessage"), object: self, userInfo: message)
//    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedWatchMessage"), object: self, userInfo: applicationContext)
//        UserDefaults.standard.set(true, forKey: "contextUpdated")
//    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        dictionaryToGolfHoleObject(message: userInfo)
    }

    func dictionaryToGolfHoleObject(message: Dictionary<String,Any>) {
        let passedInGame = GolfGame(context: persistentContainer.viewContext)
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
            let finalGame = PastGolfGame(context: persistentContainer.viewContext)
            finalGame.dateFinished = passedInGame.dateCompleted
            
            //        if golfHoleArray.count > 1 {
            //            finalGame.title = "\(golfHoleArray[0].courseName ?? "") (\(golfHoleArray.count))"
            //        } else {
            finalGame.title = passedInGame.courseName
            passedInGame.history = finalGame
        }
        saveContext()
    }
    
}

