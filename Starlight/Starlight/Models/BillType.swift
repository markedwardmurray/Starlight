//
//  BillType.swift
//  Starlight
//
//  Created by Mark Murray on 11/24/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import Foundation

protocol BillType {
    var bill_id         : String { get }
    var chamber         : String { get }
    var congress        : Int    { get }
}
