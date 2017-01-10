//
//  LegislatorsTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import INTULocationManager
import Hex

class LegislatorsTableViewController: UITableViewController, UISearchBarDelegate {
    static let navConStoryboardId = "LegislatorsNavigationController"
    
    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var saveLegislatorsButton: UIButton!
    
    var legislators: [Legislator] = DataManager.sharedInstance.homeLegislators
    let locationManager = INTULocationManager.sharedInstance()
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if DataManager.sharedInstance.homeLegislators.count == 0 {
            self.tableView.tableFooterView?.isHidden = true
            
            let onboardingAlert = UIAlertController(title: "Find Your Legislators!", message: "If you're currently at your home within the United States, Starlight can use your device's location to determine your congressional legislators.\n\nAlternatively, you may search for your legislators by entering your home's full street address in the search box.\n(Be advised that postal zip codes may contain multiple congressional districts.)\n\nStarlight does not track or record your location or your home address.", preferredStyle: .alert)
            
            let useMyAddressAction = UIAlertAction(title: "Use Address", style: .default, handler: { (action) in
                // none
            })
            onboardingAlert.addAction(useMyAddressAction)
            
            let useMyLocationAction = UIAlertAction(title: "Use Location", style: .default, handler: { (action) in
                self.loadLegislatorsWithCurrentLocation()
            })
            onboardingAlert.addAction(useMyLocationAction)
            
            self.present(onboardingAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if DataManager.sharedInstance.homeLegislators.count > 0 {
            self.loadToolbarWithHomeLegislators()
        } else {
            self.navigationController?.isToolbarHidden = true
        }
    }
    
    func loadLegislatorsWithCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: INTULocationAccuracy.neighborhood, timeout: TimeInterval(5), delayUntilAuthorized: true) { (location, accuracy, status) -> Void in
            print(status)
            
            guard let location = location else {
                self.showAlertWithTitle(title: "Error!", message: "Could not get your location")
                return;
            }
            
            self.location = location
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            SunlightAPIClient().getLegislatorsWithLat(lat: lat, lng: lng, completion: { (legislatorsResult) in
                self.updateWith(legislatorsResult: legislatorsResult)
            })
            
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if (error != nil || placemarks?.count == 0) {
                    self.navigationItem.title = "Could Not Geocode Coordinate"
                } else if let placemark = placemarks?.first {
                    self.placemark = placemark;
                    self.searchBar.text = placemark.address
                }
            })
        }
    }
    
    func updateWith(legislatorsResult: LegislatorsResult) {
        switch legislatorsResult {
        case .error(let error):
            print(error)
            self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
        case .legislators(let legislators):
            self.legislators = legislators
            self.tableView.reloadData()
            
            if self.legislators.count > 0 {
                self.tableView.tableFooterView?.isHidden = false
            }
        }
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legislators.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let legislatorCell = tableView.dequeueReusableCell(withIdentifier: "legislatorCell")!
        
        let legislator = legislators[indexPath.row]
        
        legislatorCell.textLabel?.text = legislator.fullName
        legislatorCell.detailTextLabel?.text = legislator.seatDescription
        
        return legislatorCell
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
        tableView.deselectRow(at: indexPath, animated: true)

        let legislator = legislators[indexPath.row]
        self.telprompt(legislator: legislator)
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        if let location = self.location {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            SunlightAPIClient().getLegislatorsWithLat(lat: lat, lng: lng, completion: { (legislatorsResult) in
                self.updateWith(legislatorsResult: legislatorsResult)
                if let placemark = self.placemark {
                    self.searchBar.text = placemark.address
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
                
                SunlightAPIClient.sharedInstance.getLegislatorsWithLat(lat: lat, lng: lng, completion: { (legislatorsResult) in
                    self.updateWith(legislatorsResult: legislatorsResult)
                    self.searchBar.text = placemark.address
                })
            }
        })
    }
    
    @IBAction func saveLegislatorsButtonTapped(_ sender: UIButton) {
        
        let result = DataManager.sharedInstance.save(homeLegislators: self.legislators)
        switch result {
        case .error:
            self.showAlertWithTitle(title: "Error!", message: "Failed to save your legislators")
        case .success:
            self.searchBar.resignFirstResponder()
            self.loadToolbarWithHomeLegislators()
            self.tableView.reloadData()
            
            self.showAlertWithTitle(title: "Saved!", message: "You can now call your home legislators from the bottom toolbar.")
        }
    }
    
}

