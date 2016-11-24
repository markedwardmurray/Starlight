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

enum SegmentIndex: Int {
    case legislators, upcomingBills
}

enum MainTVCReuseIdentifier: String {
    case legislatorCell, upcomingBillCell, billCell
}

class MainTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var segmentIndex: SegmentIndex = SegmentIndex.legislators
    
    var legislators: [Legislator] = []
    var upcomingBillAndBills: [(UpcomingBill, Bill?)] = []
    let locationManager = INTULocationManager.sharedInstance()
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentedControl = UISegmentedControl(items: ["Legislators","Upcoming Bills"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(sender:)), for: .valueChanged)
        segmentedControl.tintColor = UIColor.white
        segmentedControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmentedControl
        
        self.loadLegislatorsWithCurrentLocation()
        self.loadUpcomingBills()
    }
    
    func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.segmentIndex = SegmentIndex(rawValue: sender.selectedSegmentIndex)!
        sender.tintColor = UIColor.white
        sender.subviews[sender.selectedSegmentIndex].backgroundColor = UIColor.clear
        
        switch self.segmentIndex {
        case .legislators:
            self.tableView.tableHeaderView = self.searchBar
        case .upcomingBills:
            self.tableView.tableHeaderView = nil
        }
        
        self.tableView.reloadData()
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
            if self.segmentIndex == .legislators {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadUpcomingBills() {
        SunlightAPIClient.sharedInstance.getUpcomingBills { (upcomingBillsResult) in
            switch upcomingBillsResult {
            case .error(let error):
                print(error)
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .upcomingBills(let upcomingBills):
                self.upcomingBillAndBills = self.upcomingBillAndBills(upcomingBills: upcomingBills)
                
                if self.segmentIndex == .upcomingBills {
                    self.tableView.reloadData()
                }
                
                for i in 0..<self.upcomingBillAndBills.count {
                    let upcomingBillAndBill = self.upcomingBillAndBills[i]
                    let upcomingBill = upcomingBillAndBill.0
                    self.loadBill(upcomingBill: upcomingBill, row: i)
                }
            }
        }
    }
    
    func loadBill(upcomingBill: UpcomingBill, row: Int) {
        let billId = upcomingBill.bill_id
        SunlightAPIClient.sharedInstance.getBill(billId: billId, completion: { (billResult) in
            switch billResult {
            case .error(let error):
                print(error)
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .bill(let bill):
                let upcomingBillAndBill = (upcomingBill, Optional<Bill>(bill))
                self.upcomingBillAndBills[row] = upcomingBillAndBill
                if self.segmentIndex == .upcomingBills {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .left)
                }
            }
        })
    }
    
    func upcomingBillAndBills(upcomingBills: [UpcomingBill]) -> [(UpcomingBill, Bill?)] {
        var upcomingBillAndBills = [(UpcomingBill, Bill?)]()
        for upcomingBill in upcomingBills {
            upcomingBillAndBills.append((upcomingBill, nil))
        }
        
        return upcomingBillAndBills
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentIndex {
        case .legislators:
            return legislators.count
        case .upcomingBills:
            return upcomingBillAndBills.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.segmentIndex {
        case .legislators:
            let legislatorCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.legislatorCell.rawValue)!
            
            let legislator = legislators[indexPath.row]
            
            legislatorCell.textLabel?.text = legislator.fullName
            legislatorCell.detailTextLabel?.text = legislator.seatDescription
            
            return legislatorCell
            
        case .upcomingBills:
            let upcomingBillAndBill = self.upcomingBillAndBills[indexPath.row]
            if let bill = upcomingBillAndBill.1 {
                let billCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.billCell.rawValue)!
                
                billCell.textLabel?.text = bill.official_title
                billCell.detailTextLabel?.text = bill.bill_id
                
                return billCell
            }
            else {
                let upcomingBill = upcomingBillAndBill.0;
                
                let upcomingBillCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.upcomingBillCell.rawValue)!
                
                upcomingBillCell.textLabel?.text = upcomingBill.bill_id;
                
                return upcomingBillCell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.segmentIndex {
        case .legislators:
            let legislator = legislators[indexPath.row]
            if (legislator.party == "D") {
                cell.backgroundColor = UIColor.init(hex: "DAF0FF");
            } else if (legislator.party == "R") {
                cell.backgroundColor = UIColor.init(hex: "FFDFF3");
            } else {
                cell.backgroundColor = UIColor.white
            }
            break
        case .upcomingBills:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.segmentIndex {
        case .legislators:
            let legislator = legislators[indexPath.row]
            guard let url = URL(string: "telprompt://" + legislator.phone) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .upcomingBills:
            break
        }
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
    
}

