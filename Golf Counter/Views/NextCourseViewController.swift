//
//  NextCourseViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 4/27/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class NextCourseViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var courseOneButton: UIButton!
    @IBOutlet weak var courseTwoButton: UIButton!
    @IBOutlet weak var courseThreeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var golfHoleArray = [GolfGame]()
    var courseIndex = 0
    var onSelection: ((_ courseIndex: Int) -> ())?
    var blurEffect: UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPopupView()
        blurEffect = visualEffectView.effect
        visualEffectView.effect = nil
        popupView.isHidden = true
        animateIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func courseButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            onSelection?(0)
        } else if sender.tag == 2 {
            onSelection?(1)
        } else if sender.tag == 3 {
            onSelection?(2)
        } else {
            print("Unknown error when selecting course.")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        animateOut()
    }
    
    func animateIn() {
        //Setup animation of popup view
        popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupView.alpha = 0
        popupView.isHidden = false

        //Perform animation
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.effect = self.blurEffect
            self.popupView.alpha = 1
            self.popupView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        //Perform animation
        UIView.animate(withDuration: 0.2, animations: {
            self.popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupView.alpha = 0
    
        }) { (success:Bool) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupPopupView() {
        popupView.layer.cornerRadius = 15
        courseOneButton.layer.cornerRadius = 15
        courseTwoButton.layer.cornerRadius = 15
        courseThreeButton.layer.cornerRadius = 15
        courseOneButton.setTitle(golfHoleArray[0].courseName, for: .normal)
        courseTwoButton.setTitle(golfHoleArray[1].courseName, for: .normal)
        if golfHoleArray.count == 2 {
            courseThreeButton.isHidden = true
        } else if golfHoleArray.count == 3 {
            courseThreeButton.isHidden = false
            courseThreeButton.setTitle(golfHoleArray[2].courseName, for: .normal)
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
}
