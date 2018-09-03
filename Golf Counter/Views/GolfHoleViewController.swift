//
//  GolfHoleViewController.swift
//  Golf Counter
//
//  Created by Aaron Sears on 9/3/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import UIKit

class GolfHoleViewController: UITableViewController {
    
    
    var golfHoleArray = ["Hole 1", "Hole 2", "Hole 3", "Hole 4", "Hole 5", "Hole 6", "Hole 7", "Hole 8", "Hole 9", "Hole 10", "Hole 11", "Hole 12", "Hole 13", "Hole 14", "Hole 15", "Hole 16", "Hole 17", "Hole 18"]
    var holeCountArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return golfHoleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holeCell", for: indexPath)
        
        cell.textLabel?.text = golfHoleArray[indexPath.row]
        cell.detailTextLabel?.text = String(holeCountArray[indexPath.row])
        
        return cell
    }

    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToCounter", sender: self)
    }
    

}
