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
    let sunlightURL = "https://congress.api.sunlightfoundation.com/"
    
    let legislators = "legislators"
    let locate = "locate"
    let latitude = "latitude"
    let longitude = "longitude"
    
    func getLegislatorsWithLat(lat: Double, lng: Double, completion: @escaping (LegislatorsResult) -> Void) {
        
        let urlString = sunlightURL+legislators+"/"+locate+"?"+latitude+"="+String(lat)+"&"+longitude+"="+String(lng)
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
                        let legislators = Legislator.legislatorsWithResults(results: results)
                        completion(LegislatorsResult.legislators(legislators: legislators))
                    }
                }
        }
    }
    
    let upcomingBills = "upcoming_bills"
    
    func getUpcomingBills(completion: @escaping (UpcomingBillsResult) -> Void) {
        let urlString = sunlightURL+upcomingBills
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
                        
                        print("SunlightAPIClient: upcoming bills")
                        let results = json["results"]
                        let upcomingBills = UpcomingBill.upcomingBillsWithResults(results: results)
                        completion(UpcomingBillsResult.upcomingBills(upcomingBills: upcomingBills))
                    }
                }
        }
    }
    
    let bills = "bills"
    let bill_id = "bill_id"
    
    func getBill(billId: String, completion: @escaping (BillResult) -> Void) {
        let urlString = sunlightURL+bills+"?"+bill_id+"="+billId
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
                        
                        print("SunlightAPIClient: bill with id \(billId)")
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
