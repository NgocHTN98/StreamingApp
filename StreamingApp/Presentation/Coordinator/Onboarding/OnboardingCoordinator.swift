//
//  OnboardingCoordinator.swift
//  Streaming
//
//  Created by NghiaDao on 23/1/25.
//

import UIKit
import Combine

class OnboardingCoordinator: NormalCoordinator {
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController

    var cancelBag = Set<AnyCancellable>()

    var dependencyFactory: any DependencyFactoryProtocol

    init(
        navigationController: UINavigationController,
        dependencyFactory: any DependencyFactoryProtocol
    ) {
        self.navigationController = navigationController
        self.dependencyFactory = dependencyFactory
    }

    func start() {
        let liveStream = LiveStreamViewController(viewModel: LiveStreamViewModel())
        let onboardingVC = OnboardingVC()
        navigationController.pushViewController(liveStream, animated: true)
    }
}
