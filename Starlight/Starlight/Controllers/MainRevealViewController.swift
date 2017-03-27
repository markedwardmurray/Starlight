//
//  MainRevealViewController.swift
//  Starlight
//
//  Created by Mark Murray on 12/2/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import SWRevealViewController

enum MainRevealIndex: Int {
    case upcomingBills, floorUpdates, legislators, about
}

class MainRevealViewController: SWRevealViewController {
    
    private(set) var revealIndex: MainRevealIndex = .upcomingBills
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frontViewShadowColor = UIColor.white
        self.frontViewShadowRadius = 5.0
        
        /*
        if DataManager.sharedInstance.homeLegislators.count == 0 {
            self.revealIndex = .legislators
            let legislatorsRootVC = UIStoryboard.main.instantiateViewController(withIdentifier: LegislatorsTableViewController.navConStoryboardId)
            self.setFront(legislatorsRootVC, animated: false)
        }*/
    }
    
    /*
    func pushUpcomingBillsTVC() {
        self.revealIndex = .upcomingBills
        let rootVC = UIStoryboard.main.instantiateViewController(withIdentifier: UpcomingBillsTableViewController.navConStoryboardId)
        self.pushFrontViewController(rootVC, animated: true)
    }
    
    func pushFloorUpdatesTVC() {
        self.revealIndex = .floorUpdates
        let rootVC = UIStoryboard.main.instantiateViewController(withIdentifier: FloorUpdatesTableViewController.navConStoryboardId)
        self.pushFrontViewController(rootVC, animated: true)
    }

    func pushLegislatorsTVC() {
        self.revealIndex = .legislators
        let rootVC = UIStoryboard.main.instantiateViewController(withIdentifier: LegislatorsTableViewController.navConStoryboardId)
        self.pushFrontViewController(rootVC, animated: true)
    }
    
    func pushAboutTVC() {
        self.revealIndex = .about
        let rootVC = UIStoryboard.main.instantiateViewController(withIdentifier: AboutTableViewController.navConStoryboardId)
        self.pushFrontViewController(rootVC, animated: true)
    }
 */
}
