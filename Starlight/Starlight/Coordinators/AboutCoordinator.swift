//
//  AboutCoordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit
import MessageUI
import Down

class AboutCoordinator: NSObject, Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let aboutTableViewController: AboutTableViewController
    
    override init() {
        self.aboutTableViewController = AboutTableViewController.instance()
        self.navigationController = UINavigationController(rootViewController: aboutTableViewController)
        super.init()
        self.aboutTableViewController.coordinator = self
    }
    
    func start(withCompletion completion: CoordinatorCompletion?) {
        
    }
    
    func stop(withCompletion completion: CoordinatorCompletion?) {
        
    }
}

//MARK: AboutTableViewControllerCoordinator
extension AboutCoordinator: AboutTableViewControllerCoordinator {
    func aboutTableViewController(_ controller: AboutTableViewController, didSelectAboutIndex aboutIndex: AboutIndex) {
        switch aboutIndex {
        case .database:
            self.openURLToUSCongressDatabase()
        case .sunlight:
            self.openURLToSunlightLabs()
        case .oss:
            self.pushAcknowledgementsController()
        case .github:
            self.openURLToGithubStarlight()
        case .privacy:
            self.pushPrivacyController()
        case .contact:
            self.presentMailComposeController()
        }
    }
    
    func openURLToUSCongressDatabase() {
        guard let url = URL(string: "https://github.com/unitedstates/congress-legislators") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func openURLToSunlightLabs() {
        guard let url = URL(string: "https://sunlightlabs.github.io/congress") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func pushAcknowledgementsController() {
        let url_str = Bundle.main.path(forResource: "Pods-Starlight-acknowledgements", ofType: "markdown")!
        let url = URL(fileURLWithPath: url_str)
        
        self.pushMarkdownController(title: "Acknowledgements", url: url)
    }
    
    func openURLToGithubStarlight() {
        guard let url = URL(string: "https://github.com/markedwardmurray/starlight") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func pushPrivacyController() {
        guard let url = URL(string: "https://raw.githubusercontent.com/markedwardmurray/Starlight/master/PRIVACY.md") else {
            print("Invalid URL")
            return
        }
        
        self.pushMarkdownController(title: "Privacy", url: url)
    }
    
    func presentMailComposeController() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.aboutTableViewController.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.aboutTableViewController.showAlertWithTitle(title: "Error!", message: "Email is not configured on this device.")
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate
extension AboutCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            self.navigationController.showAlertWithTitle(title: "Failed to Send", message: error!.localizedDescription)
        } else {
            controller.dismiss(animated: true, completion: nil)
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
}

// MARK: Markdown controller
extension AboutCoordinator {
    func pushMarkdownController(title: String, url: URL) {
        var markdown = ""
        do {
            markdown = try String.init(contentsOf: url, encoding: .utf8)
        }
        catch {
            print(error)
            return
        }
        
        let controller = UIViewController()
        controller.title = title
        let downView = try? DownView(frame: CGRect.zero, markdownString: markdown)
        if let downView = downView {
            controller.view.addSubview(downView)
            downView.translatesAutoresizingMaskIntoConstraints = false
            downView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor).isActive = true
            downView.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
            downView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
            downView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
            
            self.navigationController.pushViewController(controller, animated: true);
        }
    }
}
