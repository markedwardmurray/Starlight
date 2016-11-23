//
//  CLPlacemark+Extensions.swift
//  Starlight
//
//  Created by Mark Murray on 11/23/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import CoreLocation

extension CLPlacemark {
    var address: String {
        var string = ""
        if let street = self.thoroughfare {
            string += street
        }
        if let city = self.locality {
            string += ", " + city
        }
        if let state = self.administrativeArea {
            string += ", " + state
        }
        if let zip = self.postalCode {
            string += " " + zip
        }
        
        return string
    }
}
