//
//  Injected.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

@propertyWrapper
struct Injected<T>: @unchecked Sendable where T: Sendable {
    var wrappedValue: T {
        DependenciesContainerManager.container[keyPath]
    }
    
    private let keyPath: KeyPath<AllDependencies, T>
    
    static subscript(_ keyPath: KeyPath<AllDependencies, T>) -> T {
        DependenciesContainerManager.container[keyPath]
    }
    
    init(_ keyPath: KeyPath<AllDependencies, T>) {
        self.keyPath = keyPath
    }
}
