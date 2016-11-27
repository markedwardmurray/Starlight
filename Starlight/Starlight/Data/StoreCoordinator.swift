//
//  StoreCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 11/26/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import SwiftyJSON

enum JSONResult {
    case error(error: Error)
    case json(json: JSON)
}

enum SuccessResult {
    case error(error: Error)
    case success(success: Bool)
}

enum StoreError: Error {
    case fileDoesNotExistAtPath
}

class StoreCoordinator {
    static let sharedInstance = StoreCoordinator()
    
    let fileManager = FileManager.default
    
    let k_dot_json = ".json"
    let k_legislators = "legislators"
    
    func modificationDate(fileName: String) -> Date? {
        let filePath = NSHomeDirectory() + "/" + fileName + k_dot_json
        do {
            let attr = try fileManager.attributesOfItem(atPath: filePath)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func loadJSON(fileName: String) -> JSONResult {
        let filePath = NSHomeDirectory() + "/" + fileName + k_dot_json
        let fileURL = URL(fileURLWithPath: filePath)
        
        guard fileManager.fileExists(atPath: filePath) else {
            print("error, no file at path")
            return JSONResult.error(error: StoreError.fileDoesNotExistAtPath)
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let json = JSON(data: data)
            return JSONResult.json(json: json)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return JSONResult.error(error: error)
        }
    }
    
    fileprivate func save(json: JSON, fileName: String) -> SuccessResult {
        let filePath = NSHomeDirectory() + "/" + fileName + k_dot_json
        
        if self.fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                return SuccessResult.error(error: error)
            }
        }
        
        do {
            let data = try json.rawData(options: .prettyPrinted)
            let fileCreated = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            return SuccessResult.success(success: fileCreated)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return SuccessResult.error(error: error)
        }
    }
    
    
    func loadLegislators() -> LegislatorsResult {
        let result = self.loadJSON(fileName: k_legislators)
        switch result {
        case .error(let error):
            return LegislatorsResult.error(error: error)
        case .json(let json):
            let legislators = Legislator.legislatorsWithResults(results: json)
            return LegislatorsResult.legislators(legislators: legislators)
        }
    }
    
    func save(legislators: [Legislator]) -> SuccessResult {
        var jsonArray = [JSON]()
        for legislator in legislators {
            jsonArray.append(legislator.json)
        }
        let json = JSON(jsonArray)
        
        return self.save(json: json, fileName: k_legislators)
    }
}

