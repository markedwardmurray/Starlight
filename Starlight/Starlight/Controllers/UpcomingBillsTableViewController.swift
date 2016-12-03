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
    
    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    var billTypes: [BillType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.loadUpcomingBills()
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
                self.billTypes = upcomingBills
                
                self.tableView.reloadData()
                
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
        return billTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let billType = self.billTypes[indexPath.row]
        if type(of: billType) == Bill.self {
            let bill = billType as! Bill
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
            
            let upcomingBillCell = tableView.dequeueReusableCell(withIdentifier: BillTypeCellReuseIdentifier.upcomingBillCell.rawValue)!
            
            upcomingBillCell.textLabel?.text = upcomingBill.bill_id;
            
            return upcomingBillCell
        }
        else {
            print("unrecognized BillType")
            return UITableViewCell()
        }
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let billType = self.billTypes[indexPath.row]
        if type(of: billType) == Bill.self {
            let bill = billType as! Bill
            if let url = bill.last_version?.urls["pdf"] {
                let webVC = WebViewController(url: url)
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

