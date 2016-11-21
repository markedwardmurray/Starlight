//
//  AboutTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/20/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import MessageUI

enum AboutTVCIndex: Int {
    case database, sunlight, oss, github, contact
}

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var tableHeaderViewLabel: UILabel!
    @IBOutlet var tableFooterViewLabel: UILabel!
    
    @IBOutlet var headerLabelHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        
        self.tableFooterViewLabel.text =
            "Made in USA\n" +
            "v\(appVersion) (\(build))"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = AboutTVCIndex(rawValue: indexPath.row)!
        switch index {
        case .database:
            self.usCongressDatabaseCellSelected()
            break;
        case .sunlight:
            self.sunlightCellSelected()
            break
        case .oss:
            break
        case .github:
            self.githubCellSelected()
            break
        case .contact:
            self.contactCellSelected()
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func usCongressDatabaseCellSelected() {
        guard let url = URL(string: "https://github.com/unitedstates/congress-legislators") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func sunlightCellSelected() {
        guard let url = URL(string: "https://sunlightlabs.github.io/congress") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func openSourceCellSelected() {
        
    }
    
    func githubCellSelected() {
        guard let url = URL(string: "https://github.com/markedwardmurray/starlight") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func contactCellSelected() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showAlertWithTitle(title: "Error!", message: "Email is not configured on this device.")
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["starlightcongress@gmail.com"])
        mailComposerVC.setSubject("iOS In-App Email")
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let firstLanguage = NSLocale.preferredLanguages.first!
        
        let messageBody = "\n\n\n" +
            "v\(appVersion) (\(build))\n" +
            "iOS \(systemVersion), \(model)\n" +
            "\(firstLanguage)"
        
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            self.showAlertWithTitle(title: "Failed to Send", message: error!.localizedDescription)
        } else {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
