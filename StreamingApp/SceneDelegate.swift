//
//  SceneDelegate.swift
//  StreamingApp
//
//  Created by Ngọc on 07/02/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var appCoordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {return}
        startApp(windowScene: windowScene)
    }

    private func startApp(windowScene: UIWindowScene) {
        let navigationController = UINavigationController()
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .blue
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        let dependencyFactory = DependencyFactory()

        self.appCoordinator = AppCoordinator(
            navigationController: navigationController,
            window: window,
            dependencyFactory: dependencyFactory
        )

        self.appCoordinator.start()
    }

}

