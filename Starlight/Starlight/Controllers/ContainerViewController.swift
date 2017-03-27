//
//  ContainerViewController.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.childViewControllers.first
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.childViewControllers.first
    }
    
    
    func setEmbeddedMainViewController(_ viewController: UIViewController) {
        if (self.childViewControllers.contains(viewController)) {
            return
        }
        
        for childVC in self.childViewControllers {
            childVC.willMove(toParentViewController: nil)
            
            if (childVC.isViewLoaded) {
                childVC.view.removeFromSuperview()
            }
            childVC.removeFromParentViewController()
        }
        
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        viewController.didMove(toParentViewController: self)
    }
}

