//
//  BaseTestCase.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

class BaseTestCase: XCTestCase {
    var dependenciesContainerDummy: DependenciesContainerDummy! // swiftlint:disable:this test_case_accessibility
    
    private var appDependencies: DependenciesContainerProtocol!
    
    override func setUp() {
        super.setUp()
        
        appDependencies = DependenciesContainerManager.container
        
        dependenciesContainerDummy = DependenciesContainerDummy()
        
        DependenciesContainerManager.container = dependenciesContainerDummy
    }
    
    override func tearDown() {
        DependenciesContainerManager.container = appDependencies
        
        let mirror = Mirror(reflecting: self)
        
        for var child in mirror.children {
            guard child.value is OptionalProtocol else { continue }
            child.value = Optional<Any>.none as Any
        }
        
        super.tearDown()
    }
}
