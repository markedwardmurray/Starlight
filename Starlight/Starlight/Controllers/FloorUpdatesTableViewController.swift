//
//  FloorUpdatesTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 1/7/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class FloorUpdatesTableViewController: UITableViewController {
    static let navConStoryboardId = "FloorUpdatesNavigationController"

    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60

        DataManager.sharedInstance.getFloorUpdatesNextPage { (indexesResult) in
            switch indexesResult {
            case .error(let error):
                self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            case .indexes(let indexes):
                var indexPaths = [IndexPath]()
                
                for index in indexes {
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
                
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadToolbarWithHomeLegislators()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.floorUpdates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let floorUpdateCell = tableView.dequeueReusableCell(withIdentifier: "floorUpdateCell", for: indexPath)

        let floorUpdate = DataManager.sharedInstance.floorUpdates.object(at: indexPath.row) as! FloorUpdate
        
        floorUpdateCell.textLabel?.text = floorUpdate.update

        return floorUpdateCell
    }

}
