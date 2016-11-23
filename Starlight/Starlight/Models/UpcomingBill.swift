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
    let source_type     : String
    let url             : String
    let chamber         : String
    let congress        : Int
    let range           : String
    let legislative_day : String
    let context         : String? // senate only
    
    init(result: JSON) {
        self.source_type     = result["source_type"].string!
        self.url             = result["url"].string!
        self.chamber         = result["chamber"].string!
        self.congress        = result["congress"].int!
        self.range           = result["range"].string!
        self.legislative_day = result["legistlative_day"].string!
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
