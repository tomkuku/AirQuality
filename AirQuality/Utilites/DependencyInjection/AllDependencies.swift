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
// DataSources
HasCacheDataSource &
HasNotificationCenter &
// Repositories
HasGIOSApiV1Repository &
HasGIOSApiRepository &
HasLocalDatabaseRepository &
HasObservedStationsFetchResultsRepository &
HasLocationRespository &
// Mappers
HasStationsNetworkMapper &
HasStationsLocalDatabaseMapper
