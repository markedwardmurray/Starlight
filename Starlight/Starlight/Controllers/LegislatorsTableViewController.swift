//
//  ViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import INTULocationManager
import Hex

class LegislatorsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var legislators: [Legislator] = []
    let locationManager = INTULocationManager.sharedInstance()
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Legislators"
        
        locationManager.requestLocation(withDesiredAccuracy: INTULocationAccuracy.neighborhood, timeout: TimeInterval(5), delayUntilAuthorized: true) { (location, accuracy, status) -> Void in
            print(status)
            
            guard let location = location else {
                self.showAlertWithTitle(title: "Error!", message: "Could not get your location")
                return;
            }
            
            self.location = location
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            SunlightAPIClient().getLegislatorsWithLat(lat: lat, lng: lng, completion: { (jsonResult) in
                self.updateWithJSONResult(jsonResult: jsonResult)
            })
            
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if (error != nil || placemarks?.count == 0) {
                    self.navigationItem.title = "Could Not Geocode Coordinate"
                } else if let placemark = placemarks?.first {
                    self.placemark = placemark;
                    self.searchBar.text = self.addressWithPlacemark(placemark: placemark)
                }
            })
        }
    }
    
    func updateWithJSONResult(jsonResult: JSONResult) {
        switch jsonResult {
        case .error(let error):
            print(error)
            self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
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
            cell.backgroundColor = UIColor.init(hex: "DAF0FF");
        } else if (legislator.party == "R") {
            cell.backgroundColor = UIColor.init(hex: "FFDFF3");
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
        searchBar.text = ""
        if let location = self.location {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            SunlightAPIClient().getLegislatorsWithLat(lat: lat, lng: lng, completion: { (jsonResult) in
                self.updateWithJSONResult(jsonResult: jsonResult)
                if let placemark = self.placemark {
                    self.searchBar.text = self.addressWithPlacemark(placemark: placemark)
                }
            })
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        geoCoder.geocodeAddressString(searchBar.text!, completionHandler: { (placemarks, error) in
            guard error == nil else {
                print(error!)
                self.showAlertWithTitle(title: "Invalid Address", message: "Could not locate that address")
                return;
            }
            
            guard placemarks?.first?.location != nil else {
                self.showAlertWithTitle(title: "Invalid Address", message: "Could not locate that address")
                return;
            }
            
            if let placemark = placemarks?.first {
                
                let lat = placemark.location!.coordinate.latitude
                let lng = placemark.location!.coordinate.longitude
                
                SunlightAPIClient.sharedInstance.getLegislatorsWithLat(lat: lat, lng: lng, completion: { (jsonResult) in
                    self.updateWithJSONResult(jsonResult: jsonResult)
                    self.searchBar.text = self.addressWithPlacemark(placemark: placemark)
                })
            }
        })
    }
    
    func addressWithPlacemark(placemark: CLPlacemark) -> String {
        var string = ""
        if let street = placemark.thoroughfare {
            string += street
        }
        if let city = placemark.locality {
            string += ", " + city
        }
        if let state = placemark.administrativeArea {
            string += ", " + state
        }
        if let zip = placemark.postalCode {
            string += " " + zip
        }
        
        return string
    }

}

