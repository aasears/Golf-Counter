//
//  HistoryTableViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 3/27/19.
//  Copyright © 2019 SearsStudio. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var pastGolfHoleArray = [PastGolfGame]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()

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
        return pastGolfHoleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath)
        cell.textLabel?.text = pastGolfHoleArray[indexPath.row].game?[0].courseName
        
        if let dateFinished = pastGolfHoleArray[indexPath.row].dateFinished {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.dateFormat = "yyyy-MM-dd"
            cell.detailTextLabel?.text = formatter.string(from: dateFinished)
        }
        
        return cell
    }


    func loadData() {
        
        let request: NSFetchRequest<PastGolfGame> = PastGolfGame.fetchRequest()
        let sort = NSSortDescriptor(key: "dateFinished", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            pastGolfHoleArray = try context.fetch(request)
        } catch {
            print("Error fetching context \(error)")
        }
    }
    
}
