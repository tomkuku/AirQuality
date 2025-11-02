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
        self[keyPath: keyPath]
    }
    
    // MARK: Others
    
    let cacheDataSource: CacheDataSourceProtocol
    let notificationCenter: NotificationCenterProtocol
    let sensorMeasurementDataFormatter: SensorMeasurementDataFormatterProtocol
    let uiApplication: UIApplicationProtocol
    
    // MARK: Repositories
    
    let giosApiV1Repository: GIOSApiV1RepositoryProtocol
    let localDatabaseRepository: LocalDatabaseRepositoryProtocol
    let observedStationsFetchResultsRepository: LocalDatabaseFetchResultsRepository<StationsLocalDatabaseMapper>
    let locationRespository: LocationRespositoryProtocol
    
    // MARK: UseCases
    
    let addObservedStationUseCase: AddObservedStationUseCaseProtocol
    let deleteObservedStationUseCase: DeleteObservedStationUseCaseProtocol
    let fetchAllStationsUseCase: FetchAllStationsUseCaseProtocol
    let getObservedStationsUseCase: GetObservedStationsUseCaseProtocol
    let findTheNearestStationUseCase: FindTheNearestStationUseCaseProtocol
    let getSensorsUseCase: GetSensorsUseCaseProtocol
    let getStationSensorsParamsUseCase: GetStationSensorsParamsUseCaseProtocol
    let getUserLocationUseCase: GetUserLocationUseCaseProtocol
    let networkConnectionMonitorUseCase: NetworkConnectionMonitorUseCaseProtocol
    let fetchArchivalMeasurementsUseCase: any FetchArchivalMeasurementsUseCaseProtocol
    
    // MARK: Mappers
    
    let stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol = StationsLocalDatabaseMapper()
    let sensorsNetworkMapper: any SensorsNetworkMapperProtocol = SensorsNetworkMapper()
    let sensorMeasurementsNetworkMapper: any SensorMeasurementNetworkMapperProtocol = SensorMeasurementNetworkMapper()
    let stationsNetworkMapper: any StationsNetworkMapperProtocol = StationsNetworkMapper()
    let stationSensorsParamsNetworkMapper: any StationSensorsParamsNetworkMapperProtocol = StationSensorsParamsNetworkMapper()
    let dtoSensorsNetworkMapper: any DTOSensorsNetworkMapperProtocol = DTOSensorsNetworkMapper()
    
    // swiftlint:disable function_body_length
    @MainActor
    init() throws {
        self.uiApplication = UIApplicationWrapper()
        
        let httpDataSource = HTTPDataSource()
        
        self.sensorMeasurementDataFormatter = SensorMeasurementDataFormatter()
        
        self.notificationCenter = NotificationCenter.default
        
        let backgroundTasksManager = BackgroundTasksManager(uiApplication: UIApplicationWrapper())
        
        self.giosApiV1Repository = GIOSApiV1Repository(httpDataSource: httpDataSource)
        
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
        self.addObservedStationUseCase = AddObservedStationUseCase()
        self.deleteObservedStationUseCase = DeleteObservedStationUseCase()
                
        self.cacheDataSource = CacheDataSource()
        
        let userLocationDataSource = UserLocationDataSource(locationManager: CLLocationManager())
        self.locationRespository = LocationRespository(userLocationDataSource: userLocationDataSource)
        
#if targetEnvironment(simulator) || TESTS
        if ProcessInfo.isPreview {
            SwiftDataPreviewAccessor.shared = .init(modelContainer: modelContainer)
            
            self.fetchAllStationsUseCase = FetchAllStationsUseCasePreviewDummy()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCasePreviewDummy()
            self.getSensorsUseCase = GetSensorsUseCasePreviewDummy()
            self.getUserLocationUseCase = GetUserLocationUseCasePreviewDummy()
            self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCasePreviewDummy()
            self.getObservedStationsUseCase = GetObservedStationsUseCasePreviewDummy()
            self.networkConnectionMonitorUseCase = NetworkConnectionMonitorUseCasePreviewDummy()
            self.fetchArchivalMeasurementsUseCase = FetchArchivalMeasurementsUseCasePreviewDummy()
        } else {
            self.fetchAllStationsUseCase = FetchAllStationsUseCase()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
            self.getSensorsUseCase = GetSensorsUseCase()
            self.getUserLocationUseCase = GetUserLocationUseCase()
            self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCase()
            self.getObservedStationsUseCase = GetObservedStationsUseCase()
            self.networkConnectionMonitorUseCase = NetworkConnectionMonitorUseCase()
            self.fetchArchivalMeasurementsUseCase = FetchArchivalMeasurementsUseCase()
        }
#else
        self.fetchAllStationsUseCase = FetchAllStationsUseCase()
        self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
        self.getSensorsUseCase = GetSensorsUseCase()
        self.getUserLocationUseCase = GetUserLocationUseCase()
        self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCase()
        self.getObservedStationsUseCase = GetObservedStationsUseCase()
        self.networkConnectionMonitorUseCase = NetworkConnectionMonitorUseCase()
        self.fetchArchivalMeasurementsUseCase = FetchArchivalMeasurementsUseCase()
#endif
    }
    // swiftlint:enable function_body_length
    
    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([StationLocalDatabaseModel.self])
        let isStoredInMemoryOnly = ProcessInfo.isPreview || ProcessInfo.isUnitTests
        
        var configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        
#if TESTS
        if ProcessInfo.containsArgument(.specificDatabaseSqlitePath) {
            guard let sqliteUrlString = ProcessInfo.processInfo.environment["UITESTS_SQLITE_PATH"],
                  let sqliteUrl = URL(string: sqliteUrlString) else {
                fatalError("sqliteUrl invalid or nil!")
            }
            configuration = ModelConfiguration(schema: schema, url: sqliteUrl, allowsSave: true)
        } else if ProcessInfo.containsArgument(.datatbaseStoreInMemoryOnly) {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        }
#endif
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

protocol HasObservedStationsFetchResultsRepository {
    var observedStationsFetchResultsRepository: LocalDatabaseFetchResultsRepository<StationsLocalDatabaseMapper> { get }
}
