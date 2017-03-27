//
//  UpcomingBillsCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class UpcomingBillsCoordinator: Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let upcomingBillsTableViewController: UpcomingBillsTableViewController
    
    init() {
        self.upcomingBillsTableViewController = UpcomingBillsTableViewController.instance()
        self.navigationController = UINavigationController(rootViewController: upcomingBillsTableViewController)
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {

    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
    }
}
