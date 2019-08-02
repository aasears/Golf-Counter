//
//  HistoryTableViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/27/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var historyTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var pastGolfGameArray = [PastGolfGame]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        historyTableView.delegate = self
        historyTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyTableView.reloadData()
    }
    
    //date formating for history page
    //        let dateStarted = Date()
    //        let formatter = DateFormatter()
    //        formatter.timeStyle = .medium
    //        formatter.dateStyle = .medium
    //        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    //        formatter.string(from: dateStarted)

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastGolfGameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath)
        cell.textLabel?.text = pastGolfGameArray[indexPath.row].title
        
        if let dateFinished = pastGolfGameArray[indexPath.row].dateFinished {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.dateFormat = "yyyy-MM-dd"
            cell.detailTextLabel?.text = formatter.string(from: dateFinished)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPastGameSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPastGameSummary" {
            let destinationVC = segue.destination as! HistoryGameViewController
            if let indexPath = historyTableView.indexPathForSelectedRow {
                destinationVC.pastGolfGame = pastGolfGameArray[indexPath.row]
            }
        }
    }
    
    //NEW
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.context.delete(self.pastGolfGameArray[indexPath.row])
            self.pastGolfGameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        save()
        return [delete]
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadData() {
        
        let request: NSFetchRequest<PastGolfGame> = PastGolfGame.fetchRequest()
        let sort = NSSortDescriptor(key: "dateFinished", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            pastGolfGameArray = try context.fetch(request)
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
        
        historyTableView.reloadData()
    }
    
}
