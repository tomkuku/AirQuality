//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    var wrappedValue: T {
        DependenciesContainerManager.container[keyPath: keyPath]
    }
    
    private let keyPath: KeyPath<DependenciesContainer, T>
    
    init(_ keyPath: KeyPath<DependenciesContainer, T>) {
        self.keyPath = keyPath
    }
}

final class DependenciesContainerManager {
    static var container: DependenciesContainer!
}

typealias AllDependencies =
HasGIOSApiRepository

struct DependenciesContainer: AllDependencies {
    var httpDataSource: HTTPDataSourceProtocol
    var giosApiRepository: GIOSApiRepositoryProtocol
    
    init() {
        self.httpDataSource = HTTPDataSource()
        self.giosApiRepository = GIOSApiRepository(httpDataSource: httpDataSource)
    }
}
