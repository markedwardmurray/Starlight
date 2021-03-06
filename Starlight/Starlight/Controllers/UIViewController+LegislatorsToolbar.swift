//
//  UIViewController+LegislatorsToolbar.swift
//  Starlight
//
//  Created by Mark Murray on 11/27/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

extension UIViewController {
    func loadToolbarWithHomeLegislators() {
        self.navigationController?.isToolbarHidden = false
        guard let toolbar = self.navigationController?.toolbar else {
            print("toolbar not found")
            return
        }
        
        let homeLegislators = DataManager.sharedInstance.homeLegislators
        
        var items = [UIBarButtonItem]()
        
        if homeLegislators.count == 0 {
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            
            let barButton = UIBarButtonItem(title: "Find Your Legislators", style: .plain, target: self, action: #selector(navigateToLegislatorsPage(sender:)) )
            barButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.init(hex: "000080")], for: .normal)
            items.append(barButton)
            
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        } else {
            let phoneIcon = UILabel()
            phoneIcon.text = "✆"
            phoneIcon.textColor = UIColor.init(hex: "808080")
            phoneIcon.textAlignment = .center
            phoneIcon.font = UIFont.systemFont(ofSize: 36)
            phoneIcon.sizeToFit()
            items.append(UIBarButtonItem(customView: phoneIcon))
            
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            
            for i in 0..<homeLegislators.count {
                let legislator = homeLegislators[i]
                
                let button = UIButton();
                button.addTarget(self, action: #selector(callLegislatorFromToolbar(sender:)), for: .touchUpInside)
                button.tag = i
                button.setTitleColor(UIColor.init(hex: "000080"), for: .normal)
                button.titleLabel?.numberOfLines = 3;
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                let title = legislator.title + "." + "\n" + legislator.first_name + "\n" + legislator.last_name
                button.setTitle(title, for: .normal)
                button.sizeToFit()
                
                let barButton = UIBarButtonItem(customView: button)
                items.append(barButton)
                
                if i < homeLegislators.count-1 {
                    items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                }
            }
        }
        
        toolbar.items = items
    }
    
    @objc fileprivate func callLegislatorFromToolbar(sender: UIButton) {
        let legislator = DataManager.sharedInstance.homeLegislators[sender.tag]
        self.telprompt(legislator: legislator)
    }
    
    @objc fileprivate func navigateToLegislatorsPage(sender: UIBarButtonItem) {
        if let mainRevealVC = self.revealViewController() as? MainRevealViewController {
            mainRevealVC.pushLegislatorsTVC()
        }
    }
    
}

