//
//  Coordinator.swift
//  Streaming
//
//  Created by NghiaDao on 23/1/25.
//

import Foundation
import UIKit
import Combine

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var cancelBag: Set<AnyCancellable> { get set }
    var dependencyFactory: DependencyFactoryProtocol { get set }
}

extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
    }

    func remove(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator })
    }
}

protocol NormalCoordinator: Coordinator {
    func start()
}

protocol TabBarChildCoordinator: Coordinator {
    func start(viewController: UIViewController)
}
