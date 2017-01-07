//
//  DataManager.swift
//  Starlight
//
//  Created by Mark Murray on 12/3/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation

typealias Index = Int

enum IndexesResult {
    case error(error: Error)
    case indexes(indexes: [Index])
}

class DataManager {
    static let sharedInstance = DataManager()
    
    var upcomingBills = [UpcomingBill]()
    var bills = Set<Bill>()
    var floorUpdates = NSMutableOrderedSet()
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
    
    func getFloorUpdatesNextPage(completion: @escaping  (IndexesResult) -> Void) {
        SunlightAPIClient.sharedInstance.getFloorUpdatesNextPage { (floorUpdatesResult) in
            switch floorUpdatesResult {
            case .error(let error):
                completion(IndexesResult.error(error: error))
            case .floorUpdates(let floorUpdates):
                let oldCount = self.floorUpdates.count
                self.floorUpdates.addObjects(from: floorUpdates)
                let newCount = self.floorUpdates.count
                let indexes = Array((oldCount)..<newCount)
                
                completion(IndexesResult.indexes(indexes: indexes))
            }
        }
    }
    
    func getFloorUpdatesRefresh(completion: @escaping (IndexesResult) -> Void) {
        SunlightAPIClient.sharedInstance.getFloorUpdatesRefresh { (floorUpdatesResult) in
            switch floorUpdatesResult {
            case .error(let error):
                completion(IndexesResult.error(error: error))
            case .floorUpdates(let floorUpdates):
                let oldCount = self.floorUpdates.count
                self.floorUpdates.insert(floorUpdates, at: IndexSet(integersIn: 0..<floorUpdates.count))
                
                let newCount = self.floorUpdates.count
                let difference = newCount - oldCount
                let indexes = Array(0..<difference)
                
                completion(IndexesResult.indexes(indexes: indexes))
            }
        }
    }
}
