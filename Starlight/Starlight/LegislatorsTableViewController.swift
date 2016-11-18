//
//  ViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

class LegislatorsTableViewController: UITableViewController {
    
    var legislators: [Legislator] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SunlightAPIClient().getLegislatorsWithLat(lat: 40.746019, lng: -73.989137, completion: { (json, error) -> Void in
            if (error != nil) {
                print("\(error)")
            } else if let json = json {
                print(json)
                let results = json["results"]
                self.legislators = Legislator.legislatorsWithResults(results: results)
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legislators.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legislatorCell")!
        
        let legislator = legislators[indexPath.row]
        
        cell.textLabel?.text = legislator.fullName
        cell.detailTextLabel?.text = legislator.phone
        
        return cell
    }

}

