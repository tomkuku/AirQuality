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
        
        let modelContainer = try Self.createModelContainer()
        
        let localDatabaseDataStore = LocalDatabaseDataStore(modelContainer: modelContainer)
        
        let fetchDescriptor = FetchDescriptor<StationLocalDatabaseModel>()
        
        let fetchResultsController = FetchResultsController<StationLocalDatabaseModel>(
            localDatabaseDataSource: localDatabaseDataStore,
            modelContainer: modelContainer,
            modelExecutor: localDatabaseDataStore.modelExecutor
        )
        
        let stationsLocalDatabaseMapper = StationsLocalDatabaseMapper()
        
        self.localDatabaseRepository = LocalDatabaseRepository(
            localDatabaseDataStore: localDatabaseDataStore,
            stationsFetchResultsController: fetchResultsController,
            stationsLocalDatabaseMapper: stationsLocalDatabaseMapper
        )
    }
    
    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([StationLocalDatabaseModel.self])
        let isStoredInMemoryOnly = ProcessInfo.isPreview || ProcessInfo.isTest
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
