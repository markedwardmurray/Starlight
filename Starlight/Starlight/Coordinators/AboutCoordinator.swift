//
//  AboutCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class AboutCoordinator: Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let aboutTableViewController: AboutTableViewController
    
    init() {
        self.aboutTableViewController = AboutTableViewController.instance()
        self.navigationController = UINavigationController(rootViewController: aboutTableViewController)
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {
        
    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
        
    }
}
