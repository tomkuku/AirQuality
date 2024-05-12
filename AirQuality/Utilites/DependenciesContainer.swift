//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

@propertyWrapper
struct Injected<T>: @unchecked Sendable {
    var wrappedValue: T {
        DependenciesContainerManager.container[keyPath: keyPath]
    }
    
    private let keyPath: KeyPath<AllDependencies, T>
    
    init(_ keyPath: KeyPath<AllDependencies, T>) {
        self.keyPath = keyPath
    }
}

enum DependenciesContainerManager: Sendable {
    // https://github.com/apple/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md
    nonisolated(unsafe) static var container: AllDependencies! // swiftlint:disable:this implicitly_unwrapped_optional
}

typealias AllDependencies =
HasGIOSApiRepository

struct DependenciesContainer: AllDependencies {
    let giosApiRepository: GIOSApiRepositoryProtocol
    
    init() {
        let httpDataSource = HTTPDataSource()
        self.giosApiRepository = GIOSApiRepository(httpDataSource: httpDataSource)
    }
}
