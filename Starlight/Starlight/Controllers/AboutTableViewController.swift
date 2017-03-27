//
//  AboutTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/20/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import MessageUI
import Down

enum AboutIndex: Int {
    case database, sunlight, oss, github, privacy, contact
}

protocol AboutTableViewControllerCoordinator: Coordinator {
    func aboutTableViewController(_ controller: AboutTableViewController, didSelectAboutIndex aboutIndex: AboutIndex)
}

class AboutTableViewController: UITableViewController {
    static func instance() -> AboutTableViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! AboutTableViewController
    }
    
    weak var coordinator: AboutTableViewControllerCoordinator?
    
    @IBOutlet var menuBarButton: UIBarButtonItem!

    @IBOutlet var tableHeaderViewLabel: UILabel!
    @IBOutlet var tableFooterViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        
        self.tableFooterViewLabel.text =
            "Made in USA\n" +
            "v\(appVersion) (\(build))"
    }
    
    //MARK: UITableViewControllerDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aboutIndex = AboutIndex(rawValue: indexPath.row)!
        
        self.coordinator?.aboutTableViewController(self, didSelectAboutIndex: aboutIndex)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
