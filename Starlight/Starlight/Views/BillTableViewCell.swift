//
//  BillTableViewCell.swift
//  Starlight
//
//  Created by Mark Murray on 11/24/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {
    
    @IBOutlet var shortTitleLabel: UILabel!
    @IBOutlet var popularTitleLabel: UILabel!
    @IBOutlet var fullTitleLabel: UILabel!
    @IBOutlet var sponsorLabel: UILabel!
    
    @IBOutlet var legislativeDayLabel: UILabel!
    @IBOutlet var contextLabel: UILabel!
    
    override func prepareForReuse() {
        self.shortTitleLabel.text = nil
        self.popularTitleLabel.text = nil
        self.fullTitleLabel.text = nil
        self.sponsorLabel.text = nil
        
        self.legislativeDayLabel.text = nil
        self.contextLabel.text = nil
    }
    
}
