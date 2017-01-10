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
    
    var upcomingBills = [UpcomingBill]()
    var bills = Set<Bill>()
    var homeLegislators = [Legislator]()
    
    func loadHomeLegislators() -> LegislatorsResult {
        let result = StoreCoordinator.sharedInstance.loadHomeLegislators()
        switch result {
        case .error(let error):
            print("Error loading home legislators: \(error.localizedDescription)")
        case .legislators(let homeLegislators):
            self.homeLegislators = homeLegislators
        }
        
        return result
    }
    
    func save(homeLegislators: [Legislator]) -> SuccessResult {
        self.homeLegislators = homeLegislators
        
        return StoreCoordinator.sharedInstance.save(homeLegislators: homeLegislators)
    }
    
    func getBill(bill_id: String, completion: @escaping (BillResult) -> Void) {
        let bill = self.bills.filter{ $0.bill_id == bill_id }.first
        if let bill = bill {
            completion(BillResult.bill(bill: bill))
            return
        }
        
        let result = StoreCoordinator.sharedInstance.loadBill(bill_id: bill_id)
        switch result {
        case .bill(let bill):
            self.bills.insert(bill)
            completion(result)
        case .error(_):
            SunlightAPIClient.sharedInstance.getBill(bill_id: bill_id, completion: { (billResult) in
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
