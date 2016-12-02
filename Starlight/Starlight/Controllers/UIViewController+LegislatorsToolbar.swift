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
            
            let button = UIButton();
            button.addTarget(self, action: #selector(callLegislatorFromToolbar(sender:)), for: .touchUpInside)
            button.tag = i
            button.setTitleColor(UIColor.blue, for: .normal)
            button.titleLabel?.numberOfLines = 3;
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            let title = legislator.title + "." + "\n" + legislator.first_name + "\n" + legislator.last_name
            button.setTitle(title, for: .normal)
            button.sizeToFit()
            
            let barButton = UIBarButtonItem(customView: button)
            
            items.append(barButton)
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        toolbar.items = items
    }
    
    @objc fileprivate func callLegislatorFromToolbar(sender: UIButton) {
        let legislator = StoreCoordinator.sharedInstance.homeLegislators[sender.tag]
        guard let url = URL(string: "telprompt://" + legislator.phone) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        print("call legislator: \(legislator.phone)")
    }
}
