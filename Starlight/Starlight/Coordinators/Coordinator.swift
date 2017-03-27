//
//  Coordinator.swift
//  Starlight
//
//  Created by Mark Murray on 3/26/17.
//  Copyright © 2017 Mark Murray. All rights reserved.
//

import Foundation

typealias CoordinatorCompletion = (Coordinator) -> Void

protocol Coordinator: class {
    
    /// A string that identifies this coordinator.
    var identifier: String { get }
    
    var childCoordinators: [Coordinator] { get set }
    
    /// Tells the coordinator to create its initial view controller and take over the user flow.
    func start(withCompletion completion: CoordinatorCompletion?)
    
    /// Tells the coordinator that it is done and that it should rewind the view controller state to where it was before `start` was called.
    func stop(withCompletion completion: CoordinatorCompletion?)
}
