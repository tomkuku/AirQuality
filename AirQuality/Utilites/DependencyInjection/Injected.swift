//
//  Injected.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

@propertyWrapper
struct Injected<T>: @unchecked Sendable {
    var wrappedValue: T {
        DependenciesContainerManager.container[keyPath]
    }
    
    private let keyPath: KeyPath<AllDependencies, T>
    
    init(_ keyPath: KeyPath<AllDependencies, T>) {
        self.keyPath = keyPath
    }
}
