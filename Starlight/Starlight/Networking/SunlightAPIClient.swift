//
//  SunlightAPIClient.swift
//  Starlight
//
//  Created by Mark Murray on 11/17/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SunlightAPIClient {
    static let sharedInstance = SunlightAPIClient()
    let sunlightURL = "https://congress.api.sunlightfoundation.com/"
    let legislators = "legislators"
    let locate = "locate"
    let latitude = "latitude"
    let longitude = "longitude"
    
    func getLegislatorsWithLat(lat: Double, lng: Double, completion: @escaping (_ json: JSON?, _ error: Error?) -> Void) {
        
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
                    completion(nil, error)
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        guard json.error == nil else {
                            print(json.error!)
                            completion(nil, json.error)
                            return;
                        }
                        
                        print("SunlightAPIClient: return fresh API response")
                        completion(json, nil)
                    }
                }
        }
    }
    
}
