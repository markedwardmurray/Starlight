//
//  DataManager.swift
//  Starlight
//
//  Created by Mark Murray on 12/3/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation

class DataManager {
    static let sharedInstance = DataManager()
    
    var upcomingBills: [UpcomingBill]?
    var bills: [Bill]?
    var homeLegislators: [Legislator] = []
    
    func loadHomeLegislators() -> LegislatorsResult {
        let result = StoreCoordinator.sharedInstance.loadHomeLegislators()
        switch result {
        case .error(_):
            break
        case .legislators(let homeLegislators):
            self.homeLegislators = homeLegislators
        }
        
        return result
    }
    
    func save(homeLegislators: [Legislator]) -> SuccessResult {
        self.homeLegislators = homeLegislators
        
        return StoreCoordinator.sharedInstance.save(homeLegislators: homeLegislators)
    }
}
