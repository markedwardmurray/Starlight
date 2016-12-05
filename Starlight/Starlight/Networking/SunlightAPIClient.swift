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

class SunlightAPIClient {
    static let sharedInstance = SunlightAPIClient()
    let k_sunlightURL = "https://congress.api.sunlightfoundation.com/"
    
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
    
    let k_upcomingBills = "upcoming_bills"
    let k_page = "page"
    var upcomingBills_page = 0
    var upcomingBills_moreResults = true
    
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
}
