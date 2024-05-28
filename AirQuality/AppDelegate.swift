//
//  AppDelegate.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/05/2024.
//

import UIKit
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let dependenciesContainer: DependenciesContainer
    
    override init() {
        do {
            self.dependenciesContainer = try DependenciesContainer()
            DependenciesContainerManager.container = dependenciesContainer
        } catch {
            fatalError("Could not create DependenciesContainer due to error: \(error.localizedDescription)")
        }
        
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }
}
