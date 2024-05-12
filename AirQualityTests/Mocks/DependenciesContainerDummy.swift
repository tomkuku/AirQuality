//
//  DependenciesContainerDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

@testable import AirQuality

final class DependenciesContainerDummy: DependenciesContainerProtocol {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T {
        get {
            guard let dependnecy = container[keyPath] as? T else {
                fatalError("Dependency \(String(describing: T.self)) not found!")
            }
            return dependnecy
        } set {
            container[keyPath] = newValue
        }
    }
    
    private var container: [PartialKeyPath<AllDependencies>: Any] = [:]
}
