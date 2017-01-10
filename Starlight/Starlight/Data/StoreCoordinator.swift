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
    case storedFileIsObsolete
}

fileprivate enum Directory {
    case temporary
    case documents
}

class StoreCoordinator {
    static let sharedInstance = StoreCoordinator()
    
    let gregorian = NSCalendar(calendarIdentifier: .gregorian)!
    
    //MARK: Private properties and methods
    
    fileprivate let fileManager = FileManager.default
    
    fileprivate let k_dot_json = ".json"
    
    fileprivate let k_folder_bills = "Bills/"
    
    fileprivate let k_file_legislators_home = "legislators_home"
    
    fileprivate func modificationDate(folderName: String?, fileName: String, directory: Directory) -> Date? {
        let filePath = self.filePath(folderName: folderName, fileName: fileName, directory: directory)
        do {
            let attr = try fileManager.attributesOfItem(atPath: filePath)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func loadJSON(folderName: String?, fileName: String, directory: Directory) -> JSONResult {
        let filePath = self.filePath(folderName: folderName, fileName: fileName, directory: directory)
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
    
    fileprivate func save(json: JSON, folderName: String?, fileName: String, directory: Directory) -> SuccessResult {
        let filePath = self.filePath(folderName: folderName, fileName: fileName, directory: directory)
        
        if let folderName = folderName {
            let error = self.createDirectoryIfNeeded(folderName: folderName, directory: directory)
            if let error = error {
                return SuccessResult.error(error: error)
            }
        }
        
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
    
    fileprivate func filePath(folderName: String?, fileName: String, directory: Directory) -> String {
        var filePath = ""
        
        switch (directory) {
        case .temporary:
            filePath += NSTemporaryDirectory()
        case .documents:
            filePath += DocumentsDirectory()
        }
        
        if let folderName = folderName {
            filePath += folderName
        }
        filePath += fileName + k_dot_json
        
        return filePath
    }
    
    fileprivate func directoryPath(folderName: String, directory: Directory) -> String {
        switch (directory) {
        case .temporary:
            return NSTemporaryDirectory() + folderName
        case .documents:
            return DocumentsDirectory() + folderName
        }
    }
    
    fileprivate func createDirectoryIfNeeded(folderName: String, directory: Directory) -> NSError? {
        let directoryPath = self.directoryPath(folderName: folderName, directory: directory)
        if self.fileManager.fileExists(atPath: directoryPath) == false {
            do {
                try self.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                return error
            }
            return nil
        } else {
            return nil
        }
    }
    
    //MARK: Public methods
    
    func loadHomeLegislators() -> LegislatorsResult {
        let result = self.loadJSON(folderName: nil, fileName: k_file_legislators_home, directory: .documents)
        switch result {
        case .error(let error):
            return LegislatorsResult.error(error: error)
        case .json(let json):
            let homeLegislators = Legislator.legislatorsWithResults(results: json)
            return LegislatorsResult.legislators(legislators: homeLegislators)
        }
    }
    
    func save(homeLegislators: [Legislator]) -> SuccessResult {
        var jsonArray = [JSON]()
        for legislator in homeLegislators {
            jsonArray.append(legislator.json)
        }
        let json = JSON(jsonArray)
        
        return self.save(json: json, folderName: nil, fileName: k_file_legislators_home, directory: .documents)
    }
    
    func loadBill(bill_id: String) -> BillResult {
        if let modificationDate = self.modificationDate(folderName: k_folder_bills, fileName: bill_id, directory: .temporary) {
            
            if self.gregorian.isDateInToday(modificationDate) == false {
                print("bill info is older than today")
                return BillResult.error(error: StoreError.storedFileIsObsolete)
            }
        }
        
        let result = self.loadJSON(folderName: k_folder_bills, fileName: bill_id, directory: .temporary)
        switch result {
        case .error(let error):
            return BillResult.error(error: error)
        case .json(let json):
            let bill = Bill(result: json)
            print("StoreCoordinator: load bill \(bill.bill_id)")
            return BillResult.bill(bill: bill)
        }
    }
    
    func save(bill: Bill) -> SuccessResult {
        print("StoreCoordinator: save bill \(bill.bill_id)")
        return self.save(json: bill.json, folderName: k_folder_bills, fileName: bill.bill_id, directory: .temporary)
    }

}

fileprivate func DocumentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return paths.first! + "/";
}

