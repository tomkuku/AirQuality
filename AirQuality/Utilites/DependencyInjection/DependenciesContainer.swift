//
//  DependenciesContainer.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation
import SwiftData
import class UIKit.UIApplication
import CoreLocation

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
    let observedStationsFetchResultsRepository: LocalDatabaseFetchResultsRepository<StationsLocalDatabaseMapper>
    let stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    let addObservedStationUseCase: AddObservedStationUseCaseProtocol
    let deleteObservedStationUseCase: DeleteObservedStationUseCaseProtocol
    let fetchAllStationsUseCase: FetchAllStationsUseCaseProtocol
    let getObservedStationsUseCase: GetObservedStationsUseCaseProtocol
    let cacheDataSource: CacheDataSourceProtocol
    let locationRespository: LocationRespositoryProtocol
    let notificationCenter: any NotificationCenterProtocol
    let stationsNetworkMapper: any StationsNetworkMapperProtocol
    let findTheNearestStationUseCase: FindTheNearestStationUseCaseProtocol
    
    @MainActor
    init() throws {
        let httpDataSource = HTTPDataSource()
        let bundleDataSource = try BundleDataSource()
        let paramsRepository = try ParamsRepository(bundleDataSource: bundleDataSource)
        let uiApplication = UIApplication.shared
        
        self.notificationCenter = NotificationCenter.default
        
        let backgroundTasksManager = BackgroundTasksManager(uiApplication: uiApplication)
        
        self.stationsNetworkMapper = StationsNetworkMapper()
        
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
        
        let stationsLocalDatabaseMapper = StationsLocalDatabaseMapper()
        
        let observedStationLocalDatabaseFetchResultsDataSource = LocalDatabaseFetchResultsDataSource<StationLocalDatabaseModel>(
            localDatabaseDataSource: localDatabaseDataSource,
            modelContainer: modelContainer,
            modelExecutor: localDatabaseDataSource.modelExecutor,
            notificationCenter: NotificationCenter.default
        )
        
        self.localDatabaseRepository = LocalDatabaseRepository(localDatabaseDataSource: localDatabaseDataSource)
        self.observedStationsFetchResultsRepository = LocalDatabaseFetchResultsRepository(
            localDatabaseFetchResultsDataSource: observedStationLocalDatabaseFetchResultsDataSource,
            mapper: stationsLocalDatabaseMapper
        )
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
        self.addObservedStationUseCase = AddObservedStationUseCase()
        self.deleteObservedStationUseCase = DeleteObservedStationUseCase()
        self.getObservedStationsUseCase = GetObservedStationsUseCase()
                
        self.cacheDataSource = CacheDataSource()
        
        let locationManager = CLLocationManager()
        
        let userLocationDataSource = UserLocationDataSource(locationManager: CLLocationManager())
        self.locationRespository = LocationRespository(userLocationDataSource: userLocationDataSource)
        
#if targetEnvironment(simulator)
        if ProcessInfo.isPreview {
            self.fetchAllStationsUseCase = FetchAllStationsUseCasePreviewDummy()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCasePreviewDummy()
        } else {
            self.fetchAllStationsUseCase = FetchAllStationsUseCase()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
        }
#else
        self.getStationsUseCase = GetStationsUseCase()
        self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
#endif
    }
    
    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([StationLocalDatabaseModel.self])
        let isStoredInMemoryOnly = ProcessInfo.isPreview || ProcessInfo.isTest
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

protocol HasObservedStationsFetchResultsRepository {
    var observedStationsFetchResultsRepository: LocalDatabaseFetchResultsRepository<StationsLocalDatabaseMapper> { get }
}
