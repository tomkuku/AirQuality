//
//  AllDependencies.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

typealias AllDependencies =
HasGIOSApiV1Repository &
HasGIOSApiRepository &
HasLocalDatabaseRepository &
HasObservedStationsFetchResultsRepository &
HasStationsLocalDatabaseMapper & 
HasGetStationsUseCase &
HasAddObservedStationUseCase &
HasDeleteObservedStationUseCase &
HasGetObservedStationsUseCase
