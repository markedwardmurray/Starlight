//
//  FlootUpdatesCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class FloorUpdatesCoordinator: Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let floorUpdatesTableViewController: FloorUpdatesTableViewController
    
    init() {
        self.floorUpdatesTableViewController = FloorUpdatesTableViewController.instance()
        self.navigationController = UINavigationController(rootViewController: floorUpdatesTableViewController)
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {
        
    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
        
    }
}
