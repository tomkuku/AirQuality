//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation
import SwiftData
import SwiftUI

protocol DependenciesContainerProtocol: AnyObject {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T { get }
}

final class DependenciesContainer: AllDependencies, DependenciesContainerProtocol {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            guard let scheardDependency = mirror.descendant(label) as? T else { continue }
            return scheardDependency
        }
        
        fatalError("Dependency \(String(describing: T.self)) not found!")
    }
    
    let giosApiV1Repository: GIOSApiV1RepositoryProtocol
    let giosApiRepository: GIOSApiRepositoryProtocol
    let appCoordinator: AppCoordinator
    var localDatabaseRepository: LocalDatabaseRepositoryProtocol
    
    init() throws {
        let httpDataSource = HTTPDataSource()
        let bundleDataSource = try BundleDataSource()
        let paramsRepository = try ParamsRepository(bundleDataSource: bundleDataSource)
        
        self.giosApiV1Repository = GIOSApiV1Repository(httpDataSource: httpDataSource)
        self.giosApiRepository = GIOSApiRepository(
            httpDataSource: httpDataSource,
            paramsRepository: paramsRepository,
            giosV1Repository: giosApiV1Repository,
            sensorsNetworkMapper: SensorsNetworkMapper(),
            measurementsNetworkMapper: MeasurementsNetworkMapper()
        )
        self.appCoordinator = AppCoordinator(navigationPath: .constant(NavigationPath()))
        
        let modelContainer = try Self.createModelContainer()
        let modelContext = ModelContext(modelContainer)
        
        let localDatabaseDataStore = LocalDatabaseDataStore(modelContainer: modelContainer)
        
        self.localDatabaseRepository = LocalDatabaseRepository(localDatabaseDataStore: localDatabaseDataStore)
    }
    
    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([StationLocalDatabaseModel.self])
        let isStoredInMemoryOnly = ProcessInfo.isPreview || ProcessInfo.isTest
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
