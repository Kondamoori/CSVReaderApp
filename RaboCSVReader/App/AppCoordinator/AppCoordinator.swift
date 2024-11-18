//
//  AppCoordinator.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import UIKit

/// Coordinating protocol
protocol Coordinating {
    /// Function to start the flow.
    /// - Returns: instance of UIViewController.
    func start() -> UIViewController
}

/// Coordinator to kick start app flow.
final class AppCoordinator: Coordinating {
    
    // MARK: - Private properties
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let appConfiguration: AppConfiguration
    
    // MARK: - Internal properties
    
    var listCoordinator: CSVDataListCoordinator?
    
    // MARK: - Initialisation
    
    /// Initialisation.
    /// - Parameters:
    ///   - window: window instance for app.
    ///   - navigationController: navigationController to maintain stack.
    ///   - appConfiguration: appConfiguration to setup dependencies.
    init(window: UIWindow, navigationController: UINavigationController = UINavigationController(), appConfiguration: AppConfiguration = AppConfiguration.default) {
        self.window = window
        self.navigationController = navigationController
        self.appConfiguration = appConfiguration
    }
    
    // MARK: - Coordinating

    func start() -> UIViewController {
        let listCoordinator = CSVDataListCoordinator(navigationController: navigationController, csvFormateProvider: appConfiguration.csvFormat, csvFileName: appConfiguration.inputFileName)
        self.listCoordinator = listCoordinator
        navigationController.viewControllers = [listCoordinator.start()]
        return navigationController
    }
}
