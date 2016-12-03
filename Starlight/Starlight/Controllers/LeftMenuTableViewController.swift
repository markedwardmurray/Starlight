//
//  LeftMenuTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 12/2/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

class LeftMenuTableViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.layer.borderWidth = 1
        selectionColor.layer.borderColor = UIColor.init(hex: "0000ff").cgColor
        selectionColor.backgroundColor = UIColor.init(hex: "0000ff")
        cell.selectedBackgroundView = selectionColor
    }
}
