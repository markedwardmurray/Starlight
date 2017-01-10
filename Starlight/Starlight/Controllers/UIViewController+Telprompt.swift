//
//  UIViewController+Telprompt.swift
//  Starlight
//
//  Created by Mark Murray on 12/5/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func telprompt(legislator: Legislator) {
        guard let url = URL(string: "telprompt://" + legislator.phone) else {
            self.showAlertWithTitle(title: "Error!", message: "Invalid phone number\n\n\(legislator.phone)\n\nfor\n\n\(legislator.fullName)")
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            self.showAlertWithTitle(title: "Error!", message: "This device is not configured for telephone calls.\n\nPlease use a telephone to call\n\(legislator.fullName)\nat\n\(legislator.phone)")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
