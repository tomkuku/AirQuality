//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

protocol DependenciesContainerProtocol {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T { get }
}

struct DependenciesContainer: AllDependencies, DependenciesContainerProtocol {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            guard let scheardDependency = mirror.descendant(label) as? T else { continue }
            return scheardDependency
        }
        
        fatalError("Dependency \(String(describing: T.self)) not found!")
    }
    
    let giosApiRepository: GIOSApiRepositoryProtocol
    
    init() throws {
        let httpDataSource = HTTPDataSource()
        let bundleDataSource = try BundleDataSource()
        
        let paramsRepository = try ParamsRepository(bundleDataSource: bundleDataSource)
        self.giosApiRepository = GIOSApiRepository(httpDataSource: httpDataSource, paramsRepository: paramsRepository)
    }
}
