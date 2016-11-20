//
//  ViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import CoreLocation

class LegislatorsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var legislators: [Legislator] = []
    let geoCoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SunlightAPIClient().getLegislatorsWithCurrentLocationWithCompletion { (jsonResult) in
            self.updateWithJSONResult(jsonResult: jsonResult)
        }
    }
    
    func updateWithJSONResult(jsonResult: JSONResult) {
        switch jsonResult {
        case .error(let error):
            print(error)
        case .json(let json):
            let results = json["results"]
            self.legislators = Legislator.legislatorsWithResults(results: results)
            self.tableView.reloadData()
        }
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legislators.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legislatorCell")!
        
        let legislator = legislators[indexPath.row]
        
        cell.textLabel?.text = legislator.fullName
        cell.detailTextLabel?.text = legislator.seatDescription
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let legislator = legislators[indexPath.row]
        if (legislator.party == "D") {
            cell.backgroundColor = UIColor.blue.withAlphaComponent(0.2);
        } else if (legislator.party == "R") {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let legislator = legislators[indexPath.row]
        guard let number = URL(string: "telprompt://" + legislator.phone) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        geoCoder.geocodeAddressString(searchBar.text!, completionHandler: { (placemarks, error) in
            guard error == nil else {
                print(error!)
                self.showAlertWithTitle(title: "Invalid Address", message: "Could not locate that address")
                return;
            }
            
            guard let location = placemarks?.first?.location else {
                self.showAlertWithTitle(title: "Invalid Address", message: "Could not locate that address")
                return;
            }
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            SunlightAPIClient.sharedInstance.getLegislatorsWithLat(lat: lat, lng: lng, completion: { (jsonResult) in
                self.updateWithJSONResult(jsonResult: jsonResult)
            })
        })
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

