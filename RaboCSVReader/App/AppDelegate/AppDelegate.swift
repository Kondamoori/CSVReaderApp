//
//  AppDelegate.swift
//  RaboCSVReader
//
//  Created by Kondamoori, S. (Srinivasarao) on 14/11/2024.
//

import Foundation
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let appCoordinator = AppCoordinator(window: window)
        window.rootViewController = appCoordinator.start()
        
        self.appCoordinator = appCoordinator
        
        window.makeKeyAndVisible()
        return true
    }
}
