//
//  UpcomingBill.swift
//  Starlight
//
//  Created by Mark Murray on 11/22/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UpcomingBillsResult {
    case error(error: Error)
    case upcomingBills(upcomingBills: [UpcomingBill])
}

struct UpcomingBill {
    let bill_id         : String
    let source_type     : String
    let url             : URL?
    let chamber         : String
    let congress        : Int
    let range           : String
    let legislative_day : Date?
    let context         : String? // senate only
    
    init(result: JSON) {
        self.bill_id         = result["bill_id"].string!
        self.source_type     = result["source_type"].string!
        self.url             = result["url"].URL
        self.chamber         = result["chamber"].string!
        self.congress        = result["congress"].int!
        self.range           = result["range"].string!
        self.legislative_day = zuluDay(string: result["legislative_day"].string)
        self.context         = result["context"].string
    }
    
    static func upcomingBillsWithResults(results: JSON) -> [UpcomingBill] {
        var upcomingBills = Array<UpcomingBill>()
        for i in 0..<results.count {
            let result = results[i]
            let upcomingBill = UpcomingBill(result: result)
            upcomingBills.append(upcomingBill)
        }
        return upcomingBills;
    }
}
