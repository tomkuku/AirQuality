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
            queue.sync {
                guard let dependnecy = self.container[keyPath] as? T else {
                    fatalError("Dependency \(String(describing: T.self)) not found!")
                }
                return dependnecy
            }
        } set {
            queue.async {
                self.container[keyPath] = newValue
            }
        }
    }
    
    private var queue = DispatchQueue(label: "com.dependencies.container.dummy")
    private var container: [PartialKeyPath<AllDependencies>: Any] = [:]
}
