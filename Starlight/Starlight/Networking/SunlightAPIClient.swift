//
//  SunlightAPIClient.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import Alamofire
import INTULocationManager
import SwiftyJSON

enum JSONResult {
    case json(json: JSON)
    case error(error: Error)
}

enum SunlightError: Error {
    case NoLocation
}

class SunlightAPIClient {
    static let sharedInstance = SunlightAPIClient()
    let sunlightURL = "https://congress.api.sunlightfoundation.com/"
    let legislators = "legislators"
    let locate = "locate"
    let latitude = "latitude"
    let longitude = "longitude"
    
    func getLegislatorsWithLat(lat: Double, lng: Double, completion: @escaping (JSONResult) -> Void) {
        
        let urlString = sunlightURL+legislators+"/"+locate+"?"+latitude+"="+String(lat)+"&"+longitude+"="+String(lng)
        let url = URL(string: urlString)!
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        Alamofire.request( request )
            .validate()
            .responseJSON { response in
                //print("Alamofire response: \(response)")
                switch response.result {
                case .failure(let error):
                    print("Alamofire error: \(error)")
                    completion(JSONResult.error(error: error))
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            let error = json.error!
                            print(error)
                            completion(JSONResult.error(error: error))
                            return;
                        }
                        
                        print("SunlightAPIClient: return fresh API response")
                        completion(JSONResult.json(json: json))
                    }
                }
        }
    }
    
    func getLegislatorsWithCurrentLocationWithCompletion(completion: @escaping (JSONResult) -> Void) {
        
        let locationManager = INTULocationManager.sharedInstance()
        
        locationManager.requestLocation(withDesiredAccuracy: INTULocationAccuracy.neighborhood, timeout: TimeInterval(5), delayUntilAuthorized: true) { (location, accuracy, status) -> Void in
            print(status)
            
            guard let location = location else {
                print("location request returned nil")
                completion(JSONResult.error(error: SunlightError.NoLocation))
                return;
            }
        
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            self.getLegislatorsWithLat(lat: lat, lng: lng, completion: { (result) in
                completion(result)
            })
        }
    }
    
}
