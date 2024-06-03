//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation
import SwiftData
import class UIKit.UIApplication

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
    let localDatabaseRepository: LocalDatabaseRepositoryProtocol
    
    @MainActor
    init() throws {
        let httpDataSource = HTTPDataSource()
        let bundleDataSource = try BundleDataSource()
        let paramsRepository = try ParamsRepository(bundleDataSource: bundleDataSource)
        let uiApplication = UIApplication.shared
        
        let backgroundTasksManager = BackgroundTasksManager(uiApplication: uiApplication)
        
        self.giosApiV1Repository = GIOSApiV1Repository(httpDataSource: httpDataSource)
        self.giosApiRepository = GIOSApiRepository(
            httpDataSource: httpDataSource,
            paramsRepository: paramsRepository,
            giosV1Repository: giosApiV1Repository,
            sensorsNetworkMapper: SensorsNetworkMapper(),
            measurementsNetworkMapper: MeasurementsNetworkMapper()
        )
        
        let modelContainer = try Self.createModelContainer()
        
        let localDatabaseDataSource = LocalDatabaseDataSource(
            modelContainer: modelContainer,
            backgroundTasksManager: backgroundTasksManager, 
            notificationCenter: NotificationCenter.default
        )
        
        let observedStationFetchedModelsController = FetchResultsController<StationLocalDatabaseModel>(
            localDatabaseDataSource: localDatabaseDataSource,
            modelContainer: modelContainer,
            modelExecutor: localDatabaseDataSource.modelExecutor
        )
        
        let stationsLocalDatabaseMapper = StationsLocalDatabaseMapper()
        
        self.localDatabaseRepository = LocalDatabaseRepository(
            localDatabaseDataSource: localDatabaseDataSource,
            stationsFetchResultsController: observedStationFetchedModelsController,
            stationsLocalDatabaseMapper: stationsLocalDatabaseMapper
        )
    }
    
    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([StationLocalDatabaseModel.self])
        let isStoredInMemoryOnly = ProcessInfo.isPreview || ProcessInfo.isTest
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
