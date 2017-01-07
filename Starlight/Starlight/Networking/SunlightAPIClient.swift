//
//  SunlightAPIClient.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SunlightError: Error {
    case resultsEmpty
}

struct SunlightPagination {
    let count : Int
    let page  : Int
    let countOnPage  : Int
    let countPerPage : Int
    
    init(json: JSON) {
        self.count = json["count"].int!
        self.page  = json["page"]["page"].int!
        self.countOnPage  = json["page"]["count"].int!
        self.countPerPage = json["page"]["per_page"].int!
    }
}

class SunlightAPIClient {
    static let sharedInstance = SunlightAPIClient()
    let k_sunlightURL = "https://congress.api.sunlightfoundation.com/"
    
    let k_page = "page"
    
    //MARK: Legislators
    
    let k_legislators = "legislators"
    let k_locate = "locate"
    let k_latitude = "latitude"
    let k_longitude = "longitude"
    
    func getLegislatorsWithLat(lat: Double, lng: Double, completion: @escaping (LegislatorsResult) -> Void) {
        
        let urlString = k_sunlightURL+k_legislators+"/"+k_locate+"?"+k_latitude+"="+String(lat)+"&"+k_longitude+"="+String(lng)
        let url = URL(string: urlString)!
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        Alamofire.request( request )
            .validate()
            .responseJSON { response in
                //print("Alamofire response: \(response)")
                switch response.result {
                case .failure(let error):
                    print("Alamofire error: \(error)")
                    completion(LegislatorsResult.error(error: error))
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            let error = json.error!
                            print(error)
                            completion(LegislatorsResult.error(error: error))
                            return;
                        }
                        
                        print("SunlightAPIClient: legislators")
                        let results = json["results"]
                        var legislators = Legislator.legislatorsWithResults(results: results)
                        
                        legislators = legislators.sorted {
                            return $0.chamber == $1.chamber ? $0.last_name < $1.last_name : $0.chamber < $1.chamber
                        }
                        
                        completion(LegislatorsResult.legislators(legislators: legislators))
                    }
                }
        }
    }
    
    // MARK: Upcoming_Bills
    
    let k_upcomingBills = "upcoming_bills"
    private(set) var upcomingBills_page = 0
    private(set) var upcomingBills_moreResults = true
    
    func getNextUpcomingBillsPage(completion: @escaping (UpcomingBillsResult) -> Void) {
        let urlString = k_sunlightURL+k_upcomingBills+"?"+k_page+"="+String(upcomingBills_page+1)
        let url = URL(string: urlString)!
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        Alamofire.request( request )
            .validate()
            .responseJSON { response in
                //print("Alamofire response: \(response)")
                switch response.result {
                case .failure(let error):
                    print("Alamofire error: \(error)")
                    completion(UpcomingBillsResult.error(error: error))
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            let error = json.error!
                            print(error)
                            completion(UpcomingBillsResult.error(error: error))
                            return;
                        }
                        let count = json["count"].int!
                        let page = json["page"]["page"].int!
                        let countOnPage = json["page"]["count"].int!
                        let countPerPage = json["page"]["per_page"].int!
                        
                        self.upcomingBills_page = page
                        let maxResult = (page-1)*countPerPage + countOnPage
                        self.upcomingBills_moreResults = count > maxResult
                        
                        print("SunlightAPIClient: upcoming bills")
                        let results = json["results"]
                        let upcomingBills = UpcomingBill.upcomingBillsWithResults(results: results)
                        completion(UpcomingBillsResult.upcomingBills(upcomingBills: upcomingBills))
                    }
                }
        }
    }
    
    //MARK: Bills
    
    let k_bills = "bills"
    let k_bill_id = "bill_id"
    
    func getBill(bill_id: String, completion: @escaping (BillResult) -> Void) {
        let urlString = k_sunlightURL+k_bills+"?"+k_bill_id+"="+bill_id
        let url = URL(string: urlString)!
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        Alamofire.request( request )
            .validate()
            .responseJSON { response in
                //print("Alamofire response: \(response)")
                switch response.result {
                case .failure(let error):
                    print("Alamofire error: \(error)")
                    completion(BillResult.error(error: error))
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            let error = json.error!
                            print(error)
                            completion(BillResult.error(error: error))
                            return;
                        }
                        
                        print("SunlightAPIClient: bill with id \(bill_id)")
                        let result = json["results"][0]
                        guard result != JSON.null else {
                            let error = SunlightError.resultsEmpty
                            completion(BillResult.error(error: error))
                            return
                        }
                        
                        let bill = Bill(result: result)
                        completion(BillResult.bill(bill: bill))
                    }
                }
        }
    }

    //MARK: Floor_Updates
    
    let k_floorUpdates = "floor_updates"
    private(set) var floorUpdates_page = 0
    private(set) var floorUpdates_lastRefreshAt: Date?
    
    func getFloorUpdatesNextPage(completion: @escaping (FloorUpdatesResult) -> Void) {
        self.getFloorUpdates(page: self.floorUpdates_page, completion: { (floorUpdatesResult, pagination) in
            switch floorUpdatesResult {
            case .error(_):
                break
            case .floorUpdates(_):
                if let pagination = pagination {
                    self.floorUpdates_page = pagination.page
                }
            }
            
            completion(floorUpdatesResult)
        })
    }
    
    func getFloorUpdatesRefresh(completion: @escaping (FloorUpdatesResult) -> Void) {
        self.getFloorUpdates(page: 0, completion: { (floorUpdatesResult, page) in
            switch floorUpdatesResult {
            case .error(_):
                break
            case .floorUpdates(_):
                self.floorUpdates_lastRefreshAt = Date()
            }
            
            completion(floorUpdatesResult)
        })
    }
    
    private func getFloorUpdates(page: Int, completion: @escaping (FloorUpdatesResult, SunlightPagination?) -> Void) {
        let urlString = k_sunlightURL+k_floorUpdates+"?"+k_page+"="+String(page+1)
        let url = URL(string: urlString)!
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        Alamofire.request( request )
            .validate()
            .responseJSON { response in
                //print("Alamofire response: \(response)")
                switch response.result {
                case .failure(let error):
                    print("Alamofire error: \(error)")
                    completion(FloorUpdatesResult.error(error: error), nil)
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            let error = json.error!
                            print(error)
                            completion(FloorUpdatesResult.error(error: error), nil)
                            return;
                        }
                        
                        let pagination = SunlightPagination(json: json)
                        
                        if self.floorUpdates_lastRefreshAt == nil {
                            self.floorUpdates_lastRefreshAt = Date()
                        }
                        
                        print("SunlightAPIClient: floor updates")
                        let results = json["results"]
                        let floorUpdates = FloorUpdate.floorUpdatesWithResults(results: results)
                        completion(FloorUpdatesResult.floorUpdates(floorUpdates: floorUpdates), pagination)
                    }
                }
        }
    }
    
}

