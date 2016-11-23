//
//  Functions.swift
//  Starlight
//
//  Created by Mark Murray on 11/23/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

func zuluDay(string: String?) -> Date? {
    guard let string = string else {
        return nil
    }
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "yyyy-MM-dd"
    
    return formatter.date(from: string)
}

func zuluTime(string: String?) -> Date? {
    guard let string = string else {
        return nil
    }
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    return formatter.date(from: string)
}

func strings(jsons: [JSON]?) -> [String] {
    guard let jsons = jsons else {
        return [String]()
    }
    
    var strings = [String]()
    for json in jsons {
        if let string = json.string {
            strings.append(string)
        }
    }
    
    return strings
}

func stringStrings(stringJSONs: [String:JSON]?) -> [String:String] {
    guard let stringJSONs = stringJSONs else {
        return [String:String]()
    }
    
    var stringStrings = [String:String]()
    for stringJSON in stringJSONs {
        if let string = stringJSON.value.string {
            stringStrings[stringJSON.key] = string
        }
    }
    
    return stringStrings
}

func stringURLs(stringJSONs: [String:JSON]?) -> [String:URL] {
    guard let stringJSONs = stringJSONs else {
        return [String:URL]()
    }
    
    var stringURLs = [String:URL]()
    for stringJSON in stringJSONs {
        if let url = stringJSON.value.URL {
            stringURLs[stringJSON.key] = url
        }
    }
    
    return stringURLs
}



