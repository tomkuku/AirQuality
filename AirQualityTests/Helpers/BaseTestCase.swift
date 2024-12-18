//
//  BaseTestCase.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest
import class Combine.AnyCancellable

@testable import AirQuality

// swiftlint:disable:next final_test_case
class BaseTestCase: XCTestCase {
    // swiftlint:disable test_case_accessibility
    var dependenciesContainerDummy: DependenciesContainerDummy!
    var expectation: XCTestExpectation!
    var appDependencies: DependenciesContainerProtocol!
    var tasks: [Task<Void, Error>]!
    var cancellables: Set<AnyCancellable>!
    // swiftlint:enable test_case_accessibility
    
    override func setUp() async throws {
        try await super.setUp()
        
        appDependencies = DependenciesContainerManager.container
        
        dependenciesContainerDummy = DependenciesContainerDummy()
        
        DependenciesContainerManager.container = dependenciesContainerDummy
        
        cancellables = .init()
        
        expectation = XCTestExpectation(description: String(describing: Self.self))
        
        tasks = []
    }
    
    override func tearDown() {
        DependenciesContainerManager.container = appDependencies
        
        for i in 0..<tasks.count {
            tasks[i].cancel()
        }
        
        let mirror = Mirror(reflecting: self)
        
        for var child in mirror.children {
            guard child.value is OptionalProtocol else { continue }
            child.value = Optional<Any>.none as Any
        }
        
        super.tearDown()
    }
    
    // swiftlint:disable test_case_accessibility
    func newTask(operation: @escaping @Sendable () async throws -> ()) rethrows {
        tasks.append(Task(operation: operation))
    }
    
    func newTask(
        operation: @escaping @Sendable () async throws -> (),
        onError: @escaping @Sendable (Error) -> ()
    ) {
        tasks.append(Task {
            do {
                try await operation()
            } catch {
                onError(error)
            }
        })
    }
    // swiftlint:enable test_case_accessibility
}
