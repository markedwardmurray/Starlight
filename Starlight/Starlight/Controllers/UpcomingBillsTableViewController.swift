//
//  UpcomingBillsTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import INTULocationManager
import Hex
import JSQWebViewController

enum BillTypeCellReuseIdentifier: String {
    case upcomingBillCell, billCell
}

class UpcomingBillsTableViewController: UITableViewController {
    static let navConStoryboardId = "UpcomingBillsNavigationController"
    
    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    var upcomingBills: [UpcomingBill] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        if let upcomingBills = DataManager.sharedInstance.upcomingBills {
            self.upcomingBills = upcomingBills
            self.tableView.reloadData()
            
            for upcomingBill in upcomingBills {
                if upcomingBill.bill == nil {
                    self.getBill(for: upcomingBill)
                }
            }
        } else {
            self.loadUpcomingBills()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadToolbarWithHomeLegislators()
    }
    
    func loadUpcomingBills() {
        SunlightAPIClient.sharedInstance.getUpcomingBills { (upcomingBillsResult) in
            switch upcomingBillsResult {
            case .error(let error):
                print(error)
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .upcomingBills(let upcomingBills):
                DataManager.sharedInstance.upcomingBills = upcomingBills
                self.upcomingBills = upcomingBills
                
                self.tableView.reloadData()
                
                for upcomingBill in upcomingBills {
                    self.getBill(for: upcomingBill)
                }
            }
        }
    }
    
    func getBill(for upcomingBill: UpcomingBill) {
        var upcomingBill = upcomingBill
        let billId = upcomingBill.bill_id
        SunlightAPIClient.sharedInstance.getBill(billId: billId, completion: { (billResult) in
            switch billResult {
            case .error(let error):
                print(error)
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .bill(let bill):
                upcomingBill.bill = bill
    
                guard let row = self.upcomingBills.index(where: { (element) -> Bool in
                    return element.bill_id == upcomingBill.bill_id
                }) else {
                    print("upcoming bill not found in array")
                    return
                }
                
                self.upcomingBills[row] = upcomingBill
                DataManager.sharedInstance.upcomingBills?[row] = upcomingBill
                DataManager.sharedInstance.bills?.append(bill)

                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .left)
            }
        })
    }
    
    //MARK: UITableViewDataSource/Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingBills.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let upcomingBill = self.upcomingBills[indexPath.row]
        if let bill = upcomingBill.bill {
            let billCell = tableView.dequeueReusableCell(withIdentifier: BillTypeCellReuseIdentifier.billCell.rawValue)! as! BillTableViewCell
            
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
            
            if let legislativeDay = upcomingBill.legislative_day {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dayText = dateFormatter.string(from: legislativeDay)
                billCell.legislativeDayLabel.text = upcomingBill.range.capitalized + " of " + dayText
            } else {
                billCell.legislativeDayLabel.text = "Undetermined Time Frame"
            }
            billCell.contextLabel.text = upcomingBill.context
            
            if bill.last_version?.urls["pdf"] != nil {
                billCell.accessoryType = .disclosureIndicator
            } else {
                billCell.accessoryType = .none
            }
            
            return billCell
        }
        else {
            let upcomingBillCell = tableView.dequeueReusableCell(withIdentifier: BillTypeCellReuseIdentifier.upcomingBillCell.rawValue)!
            
            upcomingBillCell.textLabel?.text = upcomingBill.bill_id;
            
            return upcomingBillCell
        }
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let upcomingBill = self.upcomingBills[indexPath.row]
        if let bill = upcomingBill.bill {
            if let url = bill.last_version?.urls["pdf"] {
                let webVC = WebViewController(url: url)
                self.navigationController?.pushViewController(webVC, animated: true)
                self.navigationController?.isToolbarHidden = true
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

