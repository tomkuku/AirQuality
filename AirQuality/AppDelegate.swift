//
//  AppDelegate.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/05/2024.
//

import UIKit
import SwiftUI
import SwiftData
import Combine

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
    
    var cancellables = Set<AnyCancellable>()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}
