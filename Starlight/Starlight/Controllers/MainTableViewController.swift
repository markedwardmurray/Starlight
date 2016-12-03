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
import JSQWebViewController

enum SegmentIndex: Int {
    case legislators, upcomingBills
}

enum MainTVCReuseIdentifier: String {
    case legislatorCell, upcomingBillCell, billCell
}

class MainTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var segmentIndex: SegmentIndex = SegmentIndex.legislators
    
    var legislators: [Legislator] = []
    var billTypes: [BillType] = []
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
        
        let segmentedControl = UISegmentedControl(items: ["Legislators","Upcoming Bills"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(sender:)), for: .valueChanged)
        segmentedControl.tintColor = UIColor.white
        segmentedControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmentedControl
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        let result = StoreCoordinator.sharedInstance.loadHomeLegislators()
        switch result {
        case .error:
            self.loadLegislatorsWithCurrentLocation()
        case .legislators(let legislators):
            if legislators.count == 0 {
                self.loadLegislatorsWithCurrentLocation()
            } else {
                self.legislators = legislators
                self.tableView.reloadData()
            }
        }
        
        self.loadUpcomingBills()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadToolbarWithHomeLegislators()
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
                self.billTypes = upcomingBills
                
                if self.segmentIndex == .upcomingBills {
                    self.tableView.reloadData()
                }
                
                for upcomingBill in upcomingBills {
                    self.replaceWithBill(upcomingBill: upcomingBill)
                }
            }
        }
    }
    
    func replaceWithBill(upcomingBill: UpcomingBill) {
        let billId = upcomingBill.bill_id
        SunlightAPIClient.sharedInstance.getBill(billId: billId, completion: { (billResult) in
            switch billResult {
            case .error(let error):
                print(error)
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .bill(var bill):
                bill.upcomingBill = upcomingBill
                
                guard let row = self.billTypes.index(where: { (billType) -> Bool in
                    return billType.bill_id == upcomingBill.bill_id
                }) else {
                    print("upcoming bill not found in billTypes array")
                    return
                }
                
                self.billTypes[row] = bill
                if self.segmentIndex == .upcomingBills {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .left)
                }
            }
        })
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch self.segmentIndex {
        case .legislators:
            return 2
        case .upcomingBills:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentIndex {
        case .legislators:
            switch section {
            case 0:
                return legislators.count
            case 1:
                return legislators.count > 0 ? 1 : 0
            default:
                return 0
            }
        case .upcomingBills:
            return billTypes.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.segmentIndex {
        case .legislators:
            switch indexPath.section {
            case 0:
                let legislatorCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.legislatorCell.rawValue)!
                
                let legislator = legislators[indexPath.row]
                
                legislatorCell.textLabel?.text = legislator.fullName
                legislatorCell.detailTextLabel?.text = legislator.seatDescription
                
                return legislatorCell

            case 1:
                let saveCell = UITableViewCell(style: .default, reuseIdentifier: "saveCell")
                saveCell.textLabel?.textColor = UIColor.blue
                saveCell.textLabel?.textAlignment = .center
                saveCell.textLabel?.text = "Save"
                
                return saveCell
                
            default:
                return UITableViewCell()
            }
            
        case .upcomingBills:
            let billType = self.billTypes[indexPath.row]
            if type(of: billType) == Bill.self {
                let bill = billType as! Bill
                let billCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.billCell.rawValue)! as! BillTableViewCell
                
                var shortTitleText = bill.bill_id
                if let shortTitle = bill.short_title {
                    shortTitleText += " - " + shortTitle
                }
                billCell.popularTitleLabel.text = bill.popular_title
                billCell.shortTitleLabel.text = shortTitleText
                billCell.fullTitleLabel.text = bill.official_title
                
                var sponsorLabelText = "Sponsored by " + bill.sponsorName
                if (bill.cosponsors_count > 0) {
                    sponsorLabelText += " and \(bill.cosponsors_count) others"
                }
                billCell.sponsorLabel.text = sponsorLabelText
                
                if let legislativeDay = bill.upcomingBill?.legislative_day {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let dayText = dateFormatter.string(from: legislativeDay)
                    billCell.legislativeDayLabel.text = (bill.upcomingBill?.range.capitalized)! + " of " + dayText
                } else {
                    billCell.legislativeDayLabel.text = "Undetermined Time Frame"
                }
                billCell.contextLabel.text = bill.upcomingBill?.context
                
                if bill.last_version?.urls["pdf"] != nil {
                    billCell.accessoryType = .disclosureIndicator
                } else {
                    billCell.accessoryType = .none
                }
                
                return billCell
            }
            else if type(of: billType) == UpcomingBill.self {
                let upcomingBill = billType as! UpcomingBill
                
                let upcomingBillCell = tableView.dequeueReusableCell(withIdentifier: MainTVCReuseIdentifier.upcomingBillCell.rawValue)!
                
                upcomingBillCell.textLabel?.text = upcomingBill.bill_id;
                
                return upcomingBillCell
            }
            else {
                print("unrecognized BillType")
                return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.segmentIndex {
        case .legislators:
            switch indexPath.section {
            case 0:
                let legislator = legislators[indexPath.row]
                if (legislator.party == "D") {
                    cell.backgroundColor = UIColor.init(hex: "DAF0FF");
                } else if (legislator.party == "R") {
                    cell.backgroundColor = UIColor.init(hex: "FFDFF3");
                } else {
                    cell.backgroundColor = UIColor.white
                }
                
            default:
                break
            }
            break
        case .upcomingBills:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.segmentIndex {
        case .legislators:
            switch indexPath.section {
            case 0:
                let legislator = legislators[indexPath.row]
                guard let url = URL(string: "telprompt://" + legislator.phone) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            case 1:
                let result = StoreCoordinator.sharedInstance.save(homeLegislators: self.legislators)
                switch result {
                case .error:
                    self.showAlertWithTitle(title: "Error!", message: "Failed to save your legislators")
                case .success:
                    self.loadToolbarWithHomeLegislators()
                    self.tableView.reloadData()
                    break
                }
                
            default:
                break
            }
            break
        case .upcomingBills:
            let billType = self.billTypes[indexPath.row]
            if type(of: billType) == Bill.self {
                let bill = billType as! Bill
                if let url = bill.last_version?.urls["pdf"] {
                    let webVC = WebViewController(url: url)
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            }
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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

