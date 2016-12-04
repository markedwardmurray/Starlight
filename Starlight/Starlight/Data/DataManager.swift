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
    var bills = Set<Bill>()
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
    
    func getBill(billId: String, completion: @escaping (BillResult) -> Void) {
        let result = StoreCoordinator.sharedInstance.loadBill(bill_id: billId)
        switch result {
        case .bill(let bill):
            self.bills.insert(bill)
            completion(result)
        case .error(_):
            SunlightAPIClient.sharedInstance.getBill(billId: billId, completion: { (billResult) in
                switch billResult {
                case .bill(let bill):
                    self.bills.insert(bill)
                    _ = StoreCoordinator.sharedInstance.save(bill: bill)
                case .error(_):
                    break
                }
                
                completion(billResult)
            })
        }
    }
}
