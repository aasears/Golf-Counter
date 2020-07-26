//
//  WatchSessionManager.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 7/25/20.
//  Copyright © 2020 SearsStudio. All rights reserved.
//

import WatchConnectivity
import WatchKit
import CoreData

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    
    var courseArray = [Course]()
    //var course = Course()
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default: nil
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
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
        let newCourseName = message["title"] as? String
        let newDateCreated = message["dateCreated"] as? Date
        let newCoursePar = message["par"] as? [Int]
        
        if (message["addCourse"] as! Bool) {
            //addCourse(newCourse: course)
            let course = Course(context: context)
            course.courseName = newCourseName
            course.dateCreated = newDateCreated
            course.coursePar = newCoursePar
            
        } else if (message["updateCourse"] as! Bool) {
            
            loadCourses()
            
            var index = 0
            var updateFlag = false
            
            for existingCourse in courseArray {
                if existingCourse.dateCreated == newDateCreated {
                    courseArray[index].courseName = newCourseName
                    courseArray[index].coursePar = newCoursePar
                    updateFlag = true
                }
                index += 1
            }
            
            if !updateFlag {
                let course = Course(context: context)
                course.courseName = newCourseName
                course.dateCreated = newDateCreated
                course.coursePar = newCoursePar
            }
            
        } else if (message["deleteCourse"] as! Bool) {
            
            loadCourses()
            
            var index = 0
            
            for existingCourse in courseArray {
                if existingCourse.dateCreated == newDateCreated {
                    context.delete(courseArray[index])
                }
                index += 1
            }
        }
        save()
    }
    
//    func addCourse(newCourse: Course) {
//
//        var course = Course(context: context)
//        course = newCourse
//
//        if var courseArray = UserDefaults.standard.stringArray(forKey: "courses") {
//            courseArray.append(newCourse.title)
//            UserDefaults.standard.set(courseArray, forKey: "courses")
//        } else {
//            UserDefaults.standard.set([newCourse.title], forKey: "courses")
//        }
//
//        if var parArray = UserDefaults.standard.array(forKey: "coursePar") {
//            parArray.append(newCourse.par)
//            UserDefaults.standard.set(parArray, forKey: "coursePar")
//        } else {
//            UserDefaults.standard.set([newCourse.par], forKey: "coursePar")
//        }
//
//        if var courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") {
//            courseDateCreatedArray.append(newCourse.dateCreated)
//            UserDefaults.standard.set(courseDateCreatedArray, forKey: "courseDateCreated")
//        } else {
//            UserDefaults.standard.set([newCourse.dateCreated], forKey: "courseDateCreated")
//        }
//
//    }
      
//    func updateCourse(updateCourse: Course) -> Bool {
//
//        loadCourses()
//
//        var updateFlag = false
//
//        guard var parArray = UserDefaults.standard.array(forKey: "coursePar") else {
//            print("could not establish parArray")
//            return updateFlag
//        }
//
//        guard let courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as! [Date]? else {
//            print("could not establish courseDateCreatedArray")
//            return updateFlag
//        }
//
//        if let index = courseDateCreatedArray.index(of: updateCourse.dateCreated) {
//            parArray[index] = updateCourse.par
//            UserDefaults.standard.set(parArray, forKey: "coursePar")
//            updateFlag = true
//        }
//
//
//
//        return updateFlag
//    }
//
//    func deleteCourse(deletedCourse: Course) {
//
//        loadCourses()
//
//        guard var courseArray = UserDefaults.standard.stringArray(forKey: "courses") else {
//            print("could not establish courseArray")
//            return
//        }
//        guard var parArray = UserDefaults.standard.array(forKey: "coursePar") else {
//            print("could not establish parArray")
//            return
//        }
//        guard var courseDateCreatedArray = UserDefaults.standard.array(forKey: "courseDateCreated") as! [Date]? else {
//            print("could not establish courseDateCreatedArray")
//            return
//        }
//        if let index = courseDateCreatedArray.index(of: deletedCourse.dateCreated) {
//            courseArray.remove(at: index)
//            parArray.remove(at: index)
//            courseDateCreatedArray.remove(at: index)
//            UserDefaults.standard.set(courseArray, forKey: "courses")
//            UserDefaults.standard.set(parArray, forKey: "coursePar")
//            UserDefaults.standard.set(courseDateCreatedArray, forKey: "courseDateCreated")
//        }
//
//
//        for existingCourse in courseArray {
//            if existingCourse.dateCreated == deletedCourse.dateCreated {
//
//            }
//        }
//    }
    
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
