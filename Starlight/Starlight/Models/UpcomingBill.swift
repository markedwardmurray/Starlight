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

struct UpcomingBill: Equatable {
    let bill_id         : String
    let chamber         : String
    let congress        : Int
    let context         : String? // senate only
    let legislative_day : Date?
    let range           : String
    let scheduled_at    : Date?
    let source_type     : String
    let url             : URL?
    
    var bill : Bill?
    
    init(result: JSON) {
        self.bill_id         = result["bill_id"].string!
        self.chamber         = result["chamber"].string!
        self.congress        = result["congress"].int!
        self.context         = result["context"].string
        self.legislative_day = zuluDay(string: result["legislative_day"].string)
        self.range           = result["range"].string!
        self.scheduled_at    = zuluTime(string: result["scheduled_at"].string)
        self.source_type     = result["source_type"].string!
        self.url             = result["url"].URL
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

func ==(lhs: UpcomingBill, rhs: UpcomingBill) -> Bool {
    return lhs.bill_id == rhs.bill_id
}

