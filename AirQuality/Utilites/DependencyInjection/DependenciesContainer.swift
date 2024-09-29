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
    let notificationCenter: NotificationCenterProtocol
    let stationsNetworkMapper: any StationsNetworkMapperProtocol
    let findTheNearestStationUseCase: FindTheNearestStationUseCaseProtocol
    let sensorsNetworkMapper: any SensorsNetworkMapperProtocol
    var sensorMeasurementsNetworkMapper: any SensorMeasurementNetworkMapperProtocol
    let getSensorsUseCase: GetSensorsUseCaseProtocol
    let sensorMeasurementDataFormatter: SensorMeasurementDataFormatterProtocol
    let getStationSensorsParamsUseCase: GetStationSensorsParamsUseCaseProtocol
    let stationSensorsParamsNetworkMapper: any StationSensorsParamsNetworkMapperProtocol
    let getUserLocationUseCase: GetUserLocationUseCaseProtocol
    let uiApplication: UIApplicationProtocol
    
    // swiftlint:disable function_body_length
    @MainActor
    init() throws {
        self.uiApplication = UIApplication.shared
        
        let httpDataSource = HTTPDataSource()
        
        self.sensorMeasurementDataFormatter = SensorMeasurementDataFormatter()
        
        self.notificationCenter = NotificationCenter.default
        
        let backgroundTasksManager = BackgroundTasksManager(uiApplication: UIApplication.shared)
        
        self.stationsNetworkMapper = StationsNetworkMapper()
        
        self.giosApiV1Repository = GIOSApiV1Repository(httpDataSource: httpDataSource)
        
        self.sensorsNetworkMapper = SensorsNetworkMapper()
        self.sensorMeasurementsNetworkMapper = SensorMeasurementNetworkMapper()
        
        self.giosApiRepository = GIOSApiRepository(httpDataSource: httpDataSource)
        
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
                
        self.cacheDataSource = CacheDataSource()
        
        let userLocationDataSource = UserLocationDataSource(locationManager: CLLocationManager())
        self.locationRespository = LocationRespository(userLocationDataSource: userLocationDataSource)
        
        self.stationSensorsParamsNetworkMapper = StationSensorsParamsNetworkMapper()
        
#if targetEnvironment(simulator)
        if ProcessInfo.isPreview {
            SwiftDataPreviewAccessor.shared = .init(modelContainer: modelContainer)
            
            self.fetchAllStationsUseCase = FetchAllStationsUseCasePreviewDummy()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCasePreviewDummy()
            self.getSensorsUseCase = GetSensorsUseCasePreviewDummy()
            self.getUserLocationUseCase = GetUserLocationUseCasePreviewDummy()
            self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCasePreviewDummy()
            self.getObservedStationsUseCase = GetObservedStationsUseCasePreviewDummy()
        } else {
            self.fetchAllStationsUseCase = FetchAllStationsUseCase()
            self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
            self.getSensorsUseCase = GetSensorsUseCase()
            self.getUserLocationUseCase = GetUserLocationUseCase()
            self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCase()
            self.getObservedStationsUseCase = GetObservedStationsUseCase()
        }
#else
        self.fetchAllStationsUseCase = FetchAllStationsUseCase()
        self.findTheNearestStationUseCase = FindTheNearestStationUseCase()
        self.getSensorsUseCase = GetSensorsUseCase()
        self.getUserLocationUseCase = GetUserLocationUseCase()
        self.getStationSensorsParamsUseCase = GetStationSensorsParamsUseCase()
        self.getObservedStationsUseCase = GetObservedStationsUseCase()
#endif
    }
    // swiftlint:enable function_body_length
    
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
