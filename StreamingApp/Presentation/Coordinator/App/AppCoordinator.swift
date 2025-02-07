//
//  AppCoordinator.swift
//  Streaming
//
//  Created by NghiaDao on 23/1/25.
//
import UIKit
import Combine

protocol AppCoordinatorProtocol: NormalCoordinator {
    var window: UIWindow { get set }
}

class AppCoordinator: AppCoordinatorProtocol {

    var cancelBag = Set<AnyCancellable>()
    var dependencyFactory: any DependencyFactoryProtocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var window: UIWindow

    init(
        navigationController: UINavigationController,
        window: UIWindow,
        dependencyFactory: DependencyFactoryProtocol
    ) {
        self.navigationController = navigationController
        self.window = window
        self.dependencyFactory = dependencyFactory
    }

    func start() {
        showOnboardingFlow()
    }

    func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController,
            dependencyFactory: dependencyFactory
        )
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
}
