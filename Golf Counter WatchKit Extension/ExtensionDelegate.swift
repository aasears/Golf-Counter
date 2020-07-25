//
//  ExtensionDelegate.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import WatchKit
import WatchConnectivity
import CoreData

@available(watchOSApplicationExtension 5.0, *)
class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    func applicationDidFinishLaunching() {
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        parseDictionaryFromPhone(message: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        parseCoursesFromPhone(message: userInfo)
    }
    
    func parseDictionaryFromPhone(message: Dictionary<String,Any>) {
        UserDefaults.standard.set(message["course"], forKey: "course")
        UserDefaults.standard.set(message["strokes"], forKey: "strokes")
        UserDefaults.standard.set(message["putts"], forKey: "putts")
        UserDefaults.standard.set(message["par"], forKey: "par")
        UserDefaults.standard.set(message["dateCreated"], forKey: "dateCreated")
        UserDefaults.standard.set(message["orderIdentifier"], forKey: "orderIdentifier")
        UserDefaults.standard.set(0, forKey: "net")
        UserDefaults.standard.set(true, forKey: "activeGame")
    }
    
    func parseCoursesFromPhone(message: Dictionary<String,Any>) {
        
        let course = Courses()
        course.title = message["title"] as! String
        course.dateCreated = message["dateCreated"] as! Date
        course.par = message["par"] as! [Int]
        
        if (message["addCourse"] as! Bool) {
            addCourse(newCourse: course)
            
        } else if (message["updateCourse"] as! Bool) {
            if !updateCourse(updateCourse: course) {
                addCourse(newCourse: course)
            }
            
        } else if (message["deleteCourse"] as! Bool) {
            deleteCourse(deletedCourse: course)
        }
    }
    
    func addCourse(newCourse: Courses) {
        
        if var courseArray = UserDefaults.standard.stringArray(forKey: "courses") {
            courseArray.append(newCourse.title)
            UserDefaults.standard.set(courseArray, forKey: "courses")
        } else {
            UserDefaults.standard.set([newCourse.title], forKey: "courses")
        }

        if var parArray = UserDefaults.standard.array(forKey: "coursePar") {
            parArray.append(newCourse.par)
            UserDefaults.standard.set(parArray, forKey: "coursePar")
        } else {
            UserDefaults.standard.set([newCourse.par], forKey: "coursePar")
        }

        if var courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") {
            courseDateCreatedArray.append(newCourse.dateCreated)
            UserDefaults.standard.set(courseDateCreatedArray, forKey: "courseDateCreated")
        } else {
            UserDefaults.standard.set([newCourse.dateCreated], forKey: "courseDateCreated")
        }
        
    }
    
    func updateCourse(updateCourse: Courses) -> Bool {
        
        var updateFlag = false
        
        guard var parArray = UserDefaults.standard.array(forKey: "coursePar") else {
            print("could not establish parArray")
            return updateFlag
        }
        
        guard let courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as! [Date]? else {
            print("could not establish courseDateCreatedArray")
            return updateFlag
        }
        
        if let index = courseDateCreatedArray.index(of: updateCourse.dateCreated) {
            parArray[index] = updateCourse.par
            UserDefaults.standard.set(parArray, forKey: "coursePar")
            updateFlag = true
        }
        
        return updateFlag
    }
    
    func deleteCourse(deletedCourse: Courses) {
        
        guard var courseArray = UserDefaults.standard.stringArray(forKey: "courses") else {
            print("could not establish courseArray")
            return
        }
        guard var parArray = UserDefaults.standard.array(forKey: "coursePar") else {
            print("could not establish parArray")
            return
        }
        guard var courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as! [Date]? else {
            print("could not establish courseDateCreatedArray")
            return
        }
        if let index = courseDateCreatedArray.index(of: deletedCourse.dateCreated) {
            courseArray.remove(at: index)
            parArray.remove(at: index)
            courseDateCreatedArray.remove(at: index)
            UserDefaults.standard.set(courseArray, forKey: "courses")
            UserDefaults.standard.set(parArray, forKey: "coursePar")
            UserDefaults.standard.set(courseDateCreatedArray, forKey: "courseDateCreated")
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
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
    
    @available(watchOSApplicationExtension 5.0, *)
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
