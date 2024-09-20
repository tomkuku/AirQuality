//
//  SceneDelegate.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 18/09/2024.
//

import UIKit

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}
