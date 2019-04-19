//
//  GolfHoleViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/3/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class GolfHoleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, holeTableViewCellDelegate {
    
    @IBOutlet weak var holeSummaryTableView: UITableView!
    @IBOutlet weak var nextCourseButton: UIButton!
    @IBOutlet weak var finishGameButton: UIButton!
    @IBOutlet weak var parTotalLabel: UILabel!
    @IBOutlet weak var strokesTotalLabel: UILabel!
    @IBOutlet weak var netTotalLabel: UILabel!
    @IBOutlet var nextCourseView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var courseOne: UIButton!
    @IBOutlet weak var courseTwo: UIButton!
    @IBOutlet weak var courseThree: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var golfHoleArray = [GolfGame]()
    var continueGame = false
    var courseIndex = 0
    var blurEffect: UIVisualEffect!
    
    var delegate: receiveHoleNumber?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        holeSummaryTableView.delegate = self
        holeSummaryTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = golfHoleArray[courseIndex].courseName
        setupButtons()
        displayTotals()
        blurEffect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if golfHoleArray.count > 0 {
            return golfHoleArray[courseIndex].strokeCount?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holeTableViewCell", for: indexPath) as! holeTableViewCell
        let index = courseIndex
        
        let strokes = golfHoleArray[index].strokeCount?[indexPath.row] ?? 0
        let par = golfHoleArray[index].parCount?[indexPath.row] ?? 0
        let putt = golfHoleArray[index].puttCount?[indexPath.row] ?? 0
        
        cell.accessoryType = .disclosureIndicator
        cell.setHoleFields(hole: indexPath.row + 1, stroke: strokes, par: par, putt: putt)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameSummary" {
            let destinationVC = segue.destination as! GameSummaryViewController
            destinationVC.courseIndex = courseIndex
        }
    }

    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextCourseButtonPressed(_ sender: UIButton) {
        animateIn()
    }
    
    @IBAction func completeGameButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toGameSummary", sender: self)
    }
    
    @IBAction func courseButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            courseIndex = 0
        } else if sender.tag == 2 {
            courseIndex = 1
        } else if sender.tag == 3 {
            courseIndex = 2
        } else {
            print("Unknown error when selecting course.")
        }
        animateOut()
    }
    

    func animateIn() {
        //Setup popup view - these complete smoothly with animation
        self.view.addSubview(nextCourseView)
        nextCourseView.center = self.view.center
        setupPopupView(courseCount: golfHoleArray.count)
        
        //Setup animation of popup view
        nextCourseView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        nextCourseView.alpha = 0
        visualEffectView.isHidden = false
        
        //Perform animation
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.effect = self.blurEffect
            self.nextCourseView.alpha = 1
            self.nextCourseView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        //Perform animation
        UIView.animate(withDuration: 0.2, animations: {
            self.nextCourseView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.nextCourseView.alpha = 0
            self.visualEffectView.effect = nil
            
        }) { (success:Bool) in
            //Closure items - these complete smoothly with animation
            self.nextCourseView.removeFromSuperview()
            self.visualEffectView.isHidden = true
            self.courseThree.isHidden = true
        }
    }
    
    func setupPopupView(courseCount: Int) {
        nextCourseView.layer.cornerRadius = 15
        courseOne.layer.cornerRadius = 15
        courseTwo.layer.cornerRadius = 15
        courseThree.layer.cornerRadius = 15
        courseOne.setTitle(golfHoleArray[0].courseName, for: .normal)
        courseTwo.setTitle(golfHoleArray[1].courseName, for: .normal)
        if courseCount == 2 {
            courseThree.isHidden = true
        } else if courseCount == 3 {
            courseThree.isHidden = false
            courseThree.setTitle(golfHoleArray[2].courseName, for: .normal)
        }
    }
    
    func dismissViewController(index: IndexPath) {
        delegate?.sendHoleIndex(indexNumber: index.row)
        dismiss(animated: true, completion: nil)
    }
    
    func setupButtons() {
        nextCourseButton.layer.cornerRadius = 15
        finishGameButton.layer.cornerRadius = 15
        if golfHoleArray.count <= 1 {
            nextCourseButton.isHidden = true
        }
    }
    
    func displayTotals() {
        var parSum = 0
        var strokeSum = 0
        var netSum = 0
        if let holeCount = golfHoleArray[courseIndex].parCount?.count {
            for hole in 0..<holeCount {
                let par = golfHoleArray[courseIndex].parCount?[hole] ?? 0
                let stroke = golfHoleArray[courseIndex].strokeCount?[hole] ?? 0
                if par > 0 && stroke > 0 {
                    netSum += stroke - par
                    parSum += par
                }
                if stroke > 0 {
                    strokeSum += stroke
                }
            }
        }
        if parSum > 0 {
            parTotalLabel.text = "\(parSum)"
            netTotalLabel.text = "\(netSum)"
            if netSum > 0 {
                netTotalLabel.text = "+\(netSum)"
                netTotalLabel.textColor = UIColor.red
            } else if netSum < 0 {
                netTotalLabel.textColor = UIColor.green
            } else {
                netTotalLabel.textColor = UIColor.white
            }
        } else {
            parTotalLabel.text = ""
            netTotalLabel.text = ""
        }
        strokesTotalLabel.text = "\(strokeSum)"
        
    }
    
    func sendCourseIndex(index: Int) {
        courseIndex = index
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
    
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
}
