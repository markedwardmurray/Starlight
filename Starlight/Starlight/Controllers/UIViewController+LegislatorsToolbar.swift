//
//  UIViewController+LegislatorsToolbar.swift
//  Starlight
//
//  Created by Mark Murray on 11/27/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

extension UIViewController {
    func loadToolbar(legislators: [Legislator]) {
        guard let toolbar = self.navigationController?.toolbar else {
            print("toolbar not found")
            return
        }
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        for i in 0..<legislators.count {
            let legislator = legislators[i]
            
            let label = UILabel();
            label.textColor = UIColor.blue
            label.numberOfLines = 3;
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            label.text = legislator.title + "." + "\n" + legislator.first_name + "\n" + legislator.last_name
            label.sizeToFit()
            
            let callButton = UIBarButtonItem(customView: label)
            callButton.target = self
            callButton.action = #selector(callLegislatorFromToolbar(sender:))
            callButton.tag = i
            
            items.append(callButton)
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        toolbar.items = items
    }
    
    func callLegislatorFromToolbar(sender: UIBarButtonItem) {
        let legislator = self.legislators[sender.tag]
        guard let url = URL(string: "telprompt://" + legislator.phone) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
