//
//  Legislator.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Legislator {
    let bioguide_id: String?
//    let birthday: Date?
    let chamber: String
    let contact_form: String?
    let crp_id: String?
    let district: Int?
    let fax: String?
//    let fec_ids: [String]
    let first_name: String
    let gender: String
    let govtrack_id: String?
    let icpsr_id: String?
    let in_office: Bool
    let last_name: String
    let lis_id: String?
    let middle_name: String?
    let name_suffix: String?
    let nickname: String?
    let oc_email: String?
    let ocd_id: String?
    let office: String
    let party: String
    let phone: String
    let senate_class: Int?
    let state: String
    let state_name: String
    let state_rank: String?
//    let term_end: Date
//    let term_start: Date
    let thomas_id: String?
    let title: String
    let twitter_id: String?
    let votesmart_id: String?
    let website: String?
    let youtube_id: String?
    
    var fullName: String {
        var fullName = title + ". " + first_name
        if let middle_name = middle_name {
            fullName += " " + middle_name
        }
        fullName += " " + last_name
        if let name_suffix = name_suffix {
            fullName += ", " + name_suffix
        }
        
        return fullName
    }
    
    var seatDescription: String {
        var seat = party + "-" + state + ", " + chamber.capitalized + " "
        if chamber == "senate" && senate_class != nil {
            seat += "Class \(senate_class!)"
        } else if chamber == "house" && district != nil {
            seat += "District \(district!)"
        }
        
        return seat
    }
    
    init(result: JSON) {
        self.bioguide_id  = result["bioguide_id"].string
//        self.birthday     = result["birthday"]
        self.chamber      = result["chamber"].string!
        self.contact_form = result["contact_form"].string
        self.crp_id       = result["crp_id"].string
        self.district     = result["district"].int
        self.fax          = result["fax"].string
//        self.fec_ids      = result["fec_ids"].array
        self.first_name   = result["first_name"].string!
        self.gender       = result["gender"].string!
        self.govtrack_id  = result["govtrack_id"].string
        self.icpsr_id     = result["icpsr_id"].string
        self.in_office    = result["in_office"].bool!
        self.last_name    = result["last_name"].string!
        self.lis_id       = result["lis_id"].string
        self.middle_name  = result["middle_name"].string
        self.name_suffix  = result["name_suffix"].string
        self.nickname     = result["nickname"].string
        self.oc_email     = result["oc_email"].string
        self.ocd_id       = result["ocd_id"].string
        self.office       = result["office"].string!
        self.party        = result["party"].string!
        self.phone        = result["phone"].string!
        self.senate_class = result["senate_class"].int
        self.state        = result["state"].string!
        self.state_name   = result["state_name"].string!
        self.state_rank   = result["state_rank"].string
//        self.term_end     = result["term_end"]
//        self.term_start   = result["term_start"]
        self.thomas_id    = result["thomas_id"].string
        self.title        = result["title"].string!
        self.twitter_id   = result["twitter_id"].string
        self.votesmart_id = result["votesmart_id"].string
        self.website      = result["website"].string
        self.youtube_id   = result["youtube_id"].string
    }
    
    static func legislatorsWithResults(results: JSON) -> [Legislator] {
        var legislators = Array<Legislator>()
        for i in 0..<results.count {
            let result = results[i]
            let legislator = Legislator(result: result)
            legislators.append(legislator)
        }
        return legislators;
    }
}
