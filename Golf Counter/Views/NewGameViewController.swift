//
//  NewGameViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/31/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class NewGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var selectMultipleButton: UIButton!
    @IBOutlet weak var courseSelectionTableView: UITableView!
    @IBOutlet var courseStartView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var courseOne: UIButton!
    @IBOutlet weak var courseTwo: UIButton!
    @IBOutlet weak var courseThree: UIButton!
    
    let sections = ["Standard Game", "Courses"]
    let standardGameOptions = ["9 Holes", "18 Holes"]
    
    var allowMultipleSelection = false
    var countSelected = 0
    var blurEffect: UIVisualEffect!
    var coursesSelected = [String]()
    var startingCourseIndex = 0
    
    var courseIndexPath = [IndexPath]()
    var golfHoleArray = [GolfGame]()
    var courseArray = [Course]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCourses()
        courseSelectionTableView.delegate = self
        courseSelectionTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {

        blurEffect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        selectMultipleButton.layer.cornerRadius = 15
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
        case 0:
            return standardGameOptions.count
        default:
            return courseArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newGameCourseTableViewCell", for: indexPath) as! newGameCourseTableViewCell
        cell.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            cell.courseName.text = standardGameOptions[indexPath.row]
            cell.numberOfCourseHoles.isHidden = true
            cell.holeLabel.isHidden = true
        } else {
            cell.courseName.text = courseArray[indexPath.row].courseName
            cell.numberOfCourseHoles.text = "\(courseArray[indexPath.row].coursePar?.count ?? 0)"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if countSelected > 2 { return nil }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if allowMultipleSelection {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.selectionStyle = .none
                cell.accessoryType = .checkmark
                if countSelected == 0 {
                    selectMultipleButton.setTitle("Let's Play", for: .normal)
                }
                countSelected += 1
            }
        } else {
            performSegue(withIdentifier: "goToNewGame", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            countSelected -= 1
            if countSelected == 0 {
                selectMultipleButton.setTitle("Cancel", for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! CounterViewController
        if segue.identifier == "goToNewGame" {
            
            if let indexPath = courseSelectionTableView.indexPathForSelectedRow {
                courseIndexPath = [indexPath]
            }
        }
        destinationVC.courseIndex = startingCourseIndex
        startNewGame()
    }
    
    @IBAction func selectMultipleButtonPressed(_ sender: UIButton) {
        if countSelected == 1 {
            performSegue(withIdentifier: "goToNewGame", sender: self)
        } else if countSelected > 1 {
            
            if let index = courseSelectionTableView.indexPathsForSelectedRows {
                courseIndexPath = index
                setCoursesFromSelection(rows: index)
                animateIn()
            }
        } else if !allowMultipleSelection {
            allowMultipleSelection = true
            courseSelectionTableView.allowsMultipleSelection = true
            selectMultipleButton.setTitle("Cancel", for: .normal)
        } else {
            allowMultipleSelection = false
            selectMultipleButton.setTitle("Select Multiple Courses", for: .normal)
        }
    }
    
    @IBAction func courseButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            startingCourseIndex = 0
        } else if sender.tag == 2 {
            startingCourseIndex = 1
        } else if sender.tag == 3 {
            startingCourseIndex = 2
        } else {
            print("Unknown error when selecting course.")
        }
        dismissPopup()
        performSegue(withIdentifier: "goToMultiGame", sender: self)
    }
    
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func deselectAllRows() {
        for section in 0..<courseSelectionTableView.numberOfSections {
            for row in 0..<courseSelectionTableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                courseSelectionTableView.deselectRow(at: indexPath, animated: false)
                courseSelectionTableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        }
        countSelected = 0
    }
    
    @IBAction func courseStartBackButton(_ sender: UIButton) {
        dismissPopup()
    }
    
    func setupPopupView(courseCount: Int) {
        courseStartView.layer.cornerRadius = 15
        courseOne.layer.cornerRadius = 15
        courseTwo.layer.cornerRadius = 15
        courseThree.layer.cornerRadius = 15
        courseOne.setTitle(coursesSelected[0], for: .normal)
        courseTwo.setTitle(coursesSelected[1], for: .normal)
        if courseCount == 2 {
            courseThree.isHidden = true
        } else if courseCount == 3 {
            courseThree.isHidden = false
            courseThree.setTitle(coursesSelected[2], for: .normal)
        }
    }
    
    func dismissPopup() {
        deselectAllRows()
        allowMultipleSelection = false
        selectMultipleButton.setTitle("Select Multiple Courses", for: .normal)
        animateOut()
    }
    
    func setCoursesFromSelection(rows: [IndexPath]) {
        //Clear array each time prior to setting with updated courses
        coursesSelected.removeAll()
        
        //Iterate through selections to load courses
        for index in rows {
            if index.section == 0 {
                coursesSelected.append(standardGameOptions[index.row])
            } else {
                coursesSelected.append(courseArray[index.row].courseName ?? "Error: Missing Name")
            }
        }
    }
    
    // MARK: - Animations
    
    func animateIn() {
        //Setup popup view - these complete smoothly with animation
        self.view.addSubview(courseStartView)
        courseStartView.center = self.view.center
        setupPopupView(courseCount: countSelected)
        
        //Setup animation of popup view
        courseStartView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        courseStartView.alpha = 0
        visualEffectView.isHidden = false
        
        //Perform animation
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.effect = self.blurEffect
            self.courseStartView.alpha = 1
            self.courseStartView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        //Perform animation
        UIView.animate(withDuration: 0.2, animations: {
            self.courseStartView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.courseStartView.alpha = 0
            self.visualEffectView.effect = nil
            
        }) { (success:Bool) in
            //Closure items - these complete smoothly with animation
            self.courseStartView.removeFromSuperview()
            self.visualEffectView.isHidden = true
            self.courseThree.isHidden = true
        }
    }
    
    // MARK: - New Game Functions
    
    func startNewGame() {
        
        loadData()
        
        for course in golfHoleArray {
            context.delete(course)
        }
        
        var counter = 0
        var newGameArray = [GolfGame]()
        for index in courseIndexPath {
            
            let newGame = GolfGame(context: context)
            newGame.initializeGolfGame()
            
            if index.section == 0 && index.row == 0 {
                newGame.createNewGame(holes: 9)
                newGame.courseName = "9 Hole Course"
            }
            else if index.section == 0 && index.row == 1 {
                newGame.createNewGame(holes: 18)
                newGame.courseName = "18 Hole Course"
            } else {
                if courseArray[index.row].coursePar?.count == 9 {
                    newGame.createNewGame(holes: 9)
                    newGame.courseName = courseArray[index.row].courseName
                    newGame.parCount = courseArray[index.row].coursePar
                } else {
                    newGame.createNewGame(holes: 18)
                    newGame.courseName = courseArray[index.row].courseName
                    newGame.parCount = courseArray[index.row].coursePar
                }
            }
            newGame.orderIdentifier = Int16(counter)
            counter += 1
            newGameArray.append(newGame)
        }
        golfHoleArray = newGameArray
        save()
    }

    // MARK: - CoreData functions
    
    func loadData() {
        
        let request: NSFetchRequest<GolfGame> = GolfGame.fetchRequest()
        let sort = NSSortDescriptor(key: "orderIdentifier", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            golfHoleArray = try context.fetch(request)
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
        
        courseSelectionTableView.reloadData()
    }
    
}
