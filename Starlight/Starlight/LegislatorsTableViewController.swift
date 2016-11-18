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
        
        SunlightAPIClient().getLegislatorsWithCurrentLocationWithCompletion { (jsonResult) in
            switch jsonResult {
            case .error(let error):
                print(error)
            case .json(let json):
                let results = json["results"]
                self.legislators = Legislator.legislatorsWithResults(results: results)
                self.tableView.reloadData()
            }
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let legislator = legislators[indexPath.row]
        guard let number = URL(string: "telprompt://" + legislator.phone) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

