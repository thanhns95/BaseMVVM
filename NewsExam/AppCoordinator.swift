//
//  AppCoordinator.swift
//  NewsExam
//
//  Created by it on 28/10/2022.
//

import UIKit

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private var homeCoordinator: HomeCoordinator?
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController()
        self.homeCoordinator = HomeCoordinator(navigationController: navigationController)
        self.navigationController = navigationController
    }
    
    func start() {
        window.rootViewController = self.navigationController
        homeCoordinator?.start()
        window.makeKeyAndVisible()
    }
}
