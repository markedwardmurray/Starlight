//
//  MainRevealViewController.swift
//  Starlight
//
//  Created by Mark Murray on 12/2/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import SWRevealViewController

enum RevealIndex: Int {
    case upcomingBills, floorUpdates, legislators, about
}

protocol RevealViewControllerCoordinator: Coordinator {
    var currentRevealIndex: RevealIndex { get }
}

class MainRevealViewController: SWRevealViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frontViewShadowColor = UIColor.white
        self.frontViewShadowRadius = 5.0
    }
}
