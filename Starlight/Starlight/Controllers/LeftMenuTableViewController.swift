//
//  LeftMenuTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 12/2/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

fileprivate enum LeftMenuIndex : Int {
    case upcomingBills, floorUpdates, legislators, about
}

class LeftMenuTableViewController: UITableViewController {
    var mainRevealController: MainRevealViewController {
        return self.revealViewController() as! MainRevealViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        let row: Int = self.mainRevealController.revealIndex.rawValue
        let indexPath = IndexPath(row: row, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.layer.borderWidth = 1
        selectionColor.layer.borderColor = UIColor.init(hex: "0000ff").cgColor
        selectionColor.backgroundColor = UIColor.init(hex: "0000ff")
        cell.selectedBackgroundView = selectionColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let leftMenuIndex = LeftMenuIndex(rawValue: indexPath.row)!
        
        switch leftMenuIndex {
        case .upcomingBills:
            self.mainRevealController.pushUpcomingBillsTVC()
        case .floorUpdates:
            self.mainRevealController.pushFloorUpdatesTVC()
        case .legislators:
            self.mainRevealController.pushLegislatorsTVC()
        case .about:
            self.mainRevealController.pushAboutTVC()
        }
    }
}
