//
//  LegislatorsCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class LegislatorsCoordinator: Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let legislatorsTableViewController: LegislatorsTableViewController
    
    init() {
        self.legislatorsTableViewController = LegislatorsTableViewController.instance()
        self.navigationController = UINavigationController(rootViewController: legislatorsTableViewController)
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {
        
    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
        
    }
}
