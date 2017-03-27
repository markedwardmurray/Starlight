//
//  LeftMenuTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 12/2/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

protocol LeftMenuTableViewControllerCoordinator: RevealViewControllerCoordinator {
    func leftMenuTableViewController(_ controller: LeftMenuTableViewController, didSelectRevealIndex revealIndex: RevealIndex)
}

class LeftMenuTableViewController: UITableViewController {
    static func instance() -> LeftMenuTableViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! LeftMenuTableViewController
    }
    
    weak var coordinator: LeftMenuTableViewControllerCoordinator?
    
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
    
        if let row: Int = coordinator?.currentRevealIndex.rawValue {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.layer.borderWidth = 1
        selectionColor.layer.borderColor = UIColor.init(hex: "0000ff").cgColor
        selectionColor.backgroundColor = UIColor.init(hex: "0000ff")
        cell.selectedBackgroundView = selectionColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealIndex = RevealIndex(rawValue: indexPath.row)!
        
        self.coordinator?.leftMenuTableViewController(self, didSelectRevealIndex: revealIndex)
    }
}
