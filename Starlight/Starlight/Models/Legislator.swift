//
//  Legislator.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation

enum Chamber : String {
    case senate, house
}

typealias Fax = String
typealias Phone = String
enum Gender : String {
    case M, F
}
enum Party : String {
    case R, D, I
}
enum StateRank : String {
    case junior, senior
}

struct Legislator {
    let bioguide_id: String?
    let birthday: Date?
    let chamber: Chamber
    let contact_form: String?
    let crp_id: String?
    let district: Int?
    let fax: Fax?
    let fec_ids: [String]
    let first_name: String
    let gender: Gender
    let govtrack_id: String?
    let icpsr_id: Int?
    let in_office: Bool
    let last_name: String
    let lis_id: String
    let middle_name: String?
    let name_suffix: String?
    let nickname: String?
    let oc_email: String
    let ocd_id: String
    let office: String
    let party: Party
    let phone: Phone
    let senate_class: Int
    let state: String
    let state_name: String
    let state_rank: StateRank
    let term_end: Date
    let term_start: Date
    let thomas_id: String
    let title: String
    let twitter_id: String
    let votesmart_id: Int
    let website: String
    let youtube_id: String
    
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
    
    init(bioguide_id: String?, birthday: Date?, chamber: Chamber, contact_form: String?,
         crp_id: String?, district: Int?, fax: Fax?, fec_ids: [String], first_name: String,
         gender: Gender, govtrack_id: String?, icpsr_id: Int?, in_office: Bool,
         last_name: String, lis_id: String, middle_name: String?, name_suffix: String?,
         nickname: String?, oc_email: String, ocd_id: String, office: String, party: Party,
         phone: Phone, senate_class: Int, state: String, state_name: String,
         state_rank: StateRank, term_end: Date, term_start: Date, thomas_id: String,
         title: String, twitter_id: String, votesmart_id: Int, website: String,
         youtube_id: String) {
        self.bioguide_id = bioguide_id
        self.birthday = birthday
        self.chamber = chamber
        self.contact_form = contact_form
        self.crp_id = crp_id
        self.district = district
        self.fax = fax
        self.fec_ids = fec_ids
        self.first_name = first_name
        self.gender = gender
        self.govtrack_id = govtrack_id
        self.icpsr_id = icpsr_id
        self.in_office = in_office
        self.last_name = last_name
        self.lis_id = lis_id
        self.middle_name = middle_name
        self.name_suffix = name_suffix
        self.nickname = nickname
        self.oc_email = oc_email
        self.ocd_id = ocd_id
        self.office = office
        self.party = party
        self.phone = phone
        self.senate_class = senate_class
        self.state = state
        self.state_name = state_name
        self.state_rank = state_rank
        self.term_end = term_end
        self.term_start = term_start
        self.thomas_id = thomas_id
        self.title = title
        self.twitter_id = twitter_id
        self.votesmart_id = votesmart_id
        self.website = website
        self.youtube_id = youtube_id
    }
    
    init(result: JSON) {
        self.bioguide_id  = result["bioguide_id"]
        self.birthday     = result["birthday"]
        self.chamber      = result["chamber"]
        self.contact_form = result["contact_form"]
        self.crp_id       = result["crp_id"]
        self.district     = result["district"]
        self.fax          = result["fax"]
        self.fec_ids      = result["fec_ids"]
        self.first_name   = result["first_name"]
        self.gender       = result["gender"]
        self.govtrack_id  = result["govtrack_id"]
        self.icpsr_id     = result["icpsr_id"]
        self.in_office    = result["in_office"]
        self.last_name    = result["last_name"]
        self.lis_id       = result["lis_id"]
        self.middle_name  = result["middle_name"]
        self.name_suffix  = result["name_suffix"]
        self.nickname     = result["nickname"]
        self.oc_email     = result["oc_email"]
        self.ocd_id       = result["ocd_id"]
        self.office       = result["office"]
        self.party        = result["party"]
        self.phone        = result["phone"]
        self.senate_class = result["senate_class"]
        self.state        = result["state"]
        self.state_name   = result["state_name"]
        self.state_rank   = result["state_rank"]
        self.term_end     = result["term_end"]
        self.term_start   = result["term_start"]
        self.thomas_id    = result["thomas_id"]
        self.title        = result["title"]
        self.twitter_id   = result["twitter_id"]
        self.votesmart_id = result["votesmart_id"]
        self.website      = result["website"]
        self.youtube_id   = result["youtube_id"]
    }
}
