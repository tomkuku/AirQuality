//
//  AllDependencies.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

typealias AllDependencies =
// UseCases
HasFetchAllStationsUseCase &
HasAddObservedStationUseCase &
HasDeleteObservedStationUseCase &
HasGetObservedStationsUseCase &
HasFindTheNearestStationUseCase &
HasGetSensorsUseCase &
HasGetStationSensorsParamsUseCase &
HasGetUserLocationUseCase &
HasNetworkConnectionMonitorUseCase &
// DataSources
HasCacheDataSource &
HasNotificationCenter &
// Repositories
HasGIOSApiV1Repository &
HasGIOSApiRepository &
HasLocalDatabaseRepository &
HasObservedStationsFetchResultsRepository &
HasLocationRespository &
HasGIOSApiV1Repository &
// Mappers
HasStationsNetworkMapper &
HasSensorsNetworkMapper &
HasSensorMeasurementNetworkMapper &
HasStationsLocalDatabaseMapper &
HasStationSensorsParamsNetworkMapper &
// Others
HasSensorMeasurementDataFormatter &
HasUIApplication
