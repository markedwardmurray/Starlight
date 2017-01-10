//
//  Bill.swift
//  Starlight
//
//  Created by Mark Murray on 11/22/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

enum BillResult {
    case error(error: Error)
    case bill(bill: Bill)
}

enum BillsResult {
    case error(error: Error)
    case bills(bills: [Bill])
}

struct Bill: Hashable {
    let json: JSON
    
    let bill_id     : String
    let bill_type   : String
    let chamber     : String
    let number      : Int
    let congress    : Int
    let introduced_on   : Date?
    let last_action_at  : Date?
    let last_version_on : Date?
    let last_vote_at    : Date?
    
    let last_version : BillVersion?
    let history      : BillHistory?
    
    let committee_ids   : [String]
    let cosponsors_count: Int
    let enacted_as      : String?
    let official_title  : String
    let popular_title   : String?
    let related_bill_ids: [String]
    let short_title     : String?
    let sponsor         : [String:String] // name components
    let sponsor_id      : String?
    let urls            : [String:URL]
    let withdrawn_cosponsors_count : Int
    
    var hashValue: Int {
        return self.bill_id.hashValue
    }
    
    var sponsorName: String {
        var fullName = ""
        if let title = self.sponsor["title"] {
            fullName += title + "."
        }
        if let firstName = self.sponsor["first_name"] {
            fullName += " " + firstName
        }
        if let middleName = self.sponsor["middle_name"] {
            fullName += " " + middleName
        }
        if let lastName = self.sponsor["last_name"] {
            fullName += " " + lastName
        }
        if let nameSuffix = self.sponsor["name_suffix"] {
            fullName += ", " + nameSuffix
        }

        return fullName
    }
    
    init(result: JSON) {
        self.json = result
        
        self.bill_id     = result["bill_id"].string!
        self.bill_type   = result["bill_type"].string!
        self.chamber     = result["chamber"].string!
        self.number      = result["number"].int!
        self.congress    = result["congress"].int!
        self.introduced_on   = zuluDay(string: result["introduced_on"].string)
        self.last_action_at  = zuluDay(string: result["last_action_at"].string)
        self.last_version_on = zuluDay(string: result["last_version_on"].string)
        self.last_vote_at    = zuluTime(string: result["last_vote_at"].string)
        
        self.last_version = BillVersion(json: result["last_version"])
        self.history      = BillHistory(json: result["history"])
        
        self.committee_ids   = strings(jsons: result["committee_ids"].array)
        self.cosponsors_count = result["cosponsors_count"].int!
        self.enacted_as      = result["enacted_as"].string
        self.official_title  = result["official_title"].string!
        self.popular_title   = result["popular_title"].string
        self.related_bill_ids = strings(jsons: result["related_bill_ids"].array)
        self.short_title     = result["short_title"].string
        self.sponsor         = stringStrings(stringJSONs: result["sponsor"].dictionary)
        self.sponsor_id      = result["sponsor_id"].string
        self.urls            = stringURLs(stringJSONs: result["urls"].dictionary)
        self.withdrawn_cosponsors_count = result["withdrawn_cosponsors_count"].int!
    }
    
    static func billsWithResults(results: JSON) -> [Bill] {
        var bills = Array<Bill>()
        for i in 0..<results.count {
            let result = results[i]
            let bill = Bill(result: result)
            bills.append(bill)
        }
        return bills;
    }
}

struct BillHistory {
    let active  : Bool
    let awaiting_signature : Bool
    let enacted : Bool
    let vetoed  : Bool
    
    init?(json: JSON) {
        if json == JSON.null {
            return nil
        }
        
        self.active  = json["active"].bool!
        self.awaiting_signature = json["awaiting_signature"].bool!
        self.enacted = json["enacted"].bool!
        self.vetoed  = json["vetoed"].bool!
    }
}

struct BillVersion {
    let version_code    : String
    let issued_on       : Date?
    let version_name    : String
    let bill_version_id : String
    let urls  : [String:URL] // html, pdf, xml
    let pages : Int
    
    init?(json: JSON) {
        if json == JSON.null {
            return nil
        }
        
        self.version_code    = json["version_code"].string!
        self.issued_on       = zuluDay(string: json["issued_on"].string)
        self.version_name    = json["version_name"].string!
        self.bill_version_id = json["bill_version_id"].string!
        self.urls  = stringURLs(stringJSONs: json["urls"].dictionary)
        self.pages = json["pages"].int!
    }
}

func ==(lhs: Bill, rhs: Bill) -> Bool {
    return lhs.bill_id == rhs.bill_id
}

