//
//  MainRevealCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class MainRevealCoordinator: Coordinator, LeftMenuTableViewControllerCoordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let rootViewController: ContainerViewController
    
    private(set) var leftMenuTableViewController: LeftMenuTableViewController!

    private(set) var mainRevealViewController: MainRevealViewController!
    
    let upcomingBillsCoordinator = UpcomingBillsCoordinator()
    let floorUpdatesCoordinator = FloorUpdatesCoordinator()
    let legislatorsCoordinator = LegislatorsCoordinator()
    let aboutCoordinator = AboutCoordinator()
    
    init(rootViewController: ContainerViewController) {
        self.rootViewController = rootViewController
        
        self.childCoordinators = [
            self.upcomingBillsCoordinator,
            self.floorUpdatesCoordinator,
            self.legislatorsCoordinator,
            self.aboutCoordinator
        ]
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {
        
        leftMenuTableViewController = LeftMenuTableViewController.instance()
        leftMenuTableViewController.coordinator = self
        
        mainRevealViewController = MainRevealViewController(rearViewController: leftMenuTableViewController, frontViewController: upcomingBillsCoordinator.navigationController)
        
        rootViewController.setEmbeddedMainViewController(mainRevealViewController)
        
        upcomingBillsCoordinator.start(withCompletion: nil)
    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
    }
    
    //MARK: - LeftMenuTableViewControllerCoordinator
    
    private(set) var currentRevealIndex: RevealIndex = .upcomingBills
    
    func leftMenuTableViewController(_ controller: LeftMenuTableViewController, didSelectRevealIndex revealIndex: RevealIndex) {
        self.currentRevealIndex = revealIndex
        
        switch revealIndex {
        case .upcomingBills:
            self.mainRevealViewController.pushFrontViewController(upcomingBillsCoordinator.navigationController, animated: true)
        case .floorUpdates:
            self.mainRevealViewController.pushFrontViewController(floorUpdatesCoordinator.navigationController, animated: true)
        case .legislators:
            self.mainRevealViewController.pushFrontViewController(legislatorsCoordinator.navigationController, animated: true)
        case .about:
            self.mainRevealViewController.pushFrontViewController(aboutCoordinator.navigationController, animated: true)
        }
    }
}
