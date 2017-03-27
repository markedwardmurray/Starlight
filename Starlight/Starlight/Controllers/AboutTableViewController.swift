//
//  AboutTableViewController.swift
//  Starlight
//
//  Created by Mark Murray on 11/20/16.
//  Copyright © 2016 Mark Murray. All rights reserved.
//

import UIKit
import MessageUI
import Down

enum AboutTVCIndex: Int {
    case database, sunlight, oss, github, privacy, contact
}

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    static func instance() -> AboutTableViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! AboutTableViewController
    }
    
    @IBOutlet var menuBarButton: UIBarButtonItem!

    @IBOutlet var tableHeaderViewLabel: UILabel!
    @IBOutlet var tableFooterViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBarButton.target = self.revealViewController()
            self.menuBarButton.action = Selector(("revealToggle:"))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
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
        case .sunlight:
            self.sunlightCellSelected()
        case .oss:
            self.openSourceCellSelected()
        case .github:
            self.githubCellSelected()
        case .privacy:
            self.privacyCellSelected()
        case .contact:
            self.contactCellSelected()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func privacyCellSelected() {
        guard let url = URL(string: "https://raw.githubusercontent.com/markedwardmurray/Starlight/master/PRIVACY.md") else {
            print("Invalid URL")
            return
        }
        
        self.pushMarkdownController(title: "Privacy", url: url)
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
        let url_str = Bundle.main.path(forResource: "Pods-Starlight-acknowledgements", ofType: "markdown")!
        let url = URL(fileURLWithPath: url_str)
        
        self.pushMarkdownController(title: "Acknowledgements", url: url)
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
    
    //MARK: Helpers
    
    private func pushMarkdownController(title: String, url: URL) {
        var markdown = ""
        do {
            markdown = try String.init(contentsOf: url, encoding: .utf8)
        }
        catch {
            self.showAlertWithTitle(title: "Error!", message: error.localizedDescription)
            return
        }
        
        let controller = UIViewController()
        controller.title = title
        let downView = try? DownView(frame: self.view.frame, markdownString: markdown)
        if let downView = downView {
            controller.view.addSubview(downView)
            downView.translatesAutoresizingMaskIntoConstraints = false
            downView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor).isActive = true
            downView.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
            downView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
            downView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
            
            self.navigationController?.pushViewController(controller, animated: true);
        }
    }
}
