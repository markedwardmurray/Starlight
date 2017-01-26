//
//  FloorUpdate.swift
//  Starlight
//
//  Created by Mark Murray on 1/7/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import SwiftyJSON

enum FloorUpdatesResult {
    case error(error: Error)
    case floorUpdates(floorUpdates: [FloorUpdate])
}

class FloorUpdate: NSObject, JSQMessageData, Comparable {
    let update   : String
    let timestamp: Date
    let chamber  : String
    
    let congress : Int?
    let year     : Int?
    let legislative_day : Date?
    let category : String?
    
    let bill_ids       : Array<String>
    let roll_ids       : Array<String>
    let legislator_ids : Array<String>
    
    init(result: JSON) {
        self.update          = result["update"].string!
        self.timestamp       = zuluTimeFloorUpdate(string: result["timestamp"].string)!
        self.chamber         = result["chamber"].string!
        
        self.congress        = result["congress"].int
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
    
    //MARK: JSQMessageData
    func senderId() -> String? {
        return self.chamber
    }
    func senderDisplayName() -> String? {
        return self.chamber.capitalized
    }
    func date() -> Date? {
        return Optional<Date>(self.timestamp)
    }
    func isMediaMessage() -> Bool {
        return false
    }
    func messageHash() -> UInt {
        return UInt(self.hashValue)
    }
    func text() -> String? {
        return self.update
    }
}

func == (lhs: FloorUpdate, rhs: FloorUpdate) -> Bool {
    return lhs.timestamp == rhs.timestamp
}

func < (lhs: FloorUpdate, rhs: FloorUpdate) -> Bool {
    return lhs.timestamp < rhs.timestamp
}
