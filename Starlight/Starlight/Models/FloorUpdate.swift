//
//  FloorUpdate.swift
//  Starlight
//
//  Created by Mark Murray on 1/7/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FloorUpdate {
    let update   : String
    
    let chamber  : String
    let timestamp: Date
    let congress : Int
    let year     : Int?
    let legislative_day : Date?
    let category : String?
    
    let bill_ids       : Array<String>
    let roll_ids       : Array<String>
    let legislator_ids : Array<String>
    
    init(result: JSON) {
        self.update          = result["update"].string!
        
        self.timestamp       = zuluTime(string: result["timestamp"].string)!
        self.chamber         = result["chamber"].string!
        self.congress        = result["congress"].int!
        self.year            = result["year"].int
        self.legislative_day = zuluDay(string: result["legislative_day"].string)
        self.category        = result["category"].string
        
        self.bill_ids        = strings(jsons: result["bill_ids"].array)
        self.roll_ids        = strings(jsons: result["roll_ids"].array)
        self.legislator_ids  = strings(jsons: result["legislator_ids"].array)
    }
    
    static func floorUpdatesWithResults(results: JSON) -> [FloorUpdate] {
        var floorUpdates = Array<FloorUpdate>()
        for i in 0..<results.count {
            let result = results[i]
            let floorUpdate = FloorUpdate(result: result)
            floorUpdates.append(floorUpdate)
        }
        return floorUpdates;
    }
}



