//
//  GetMeasuredStationParametersUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/06/2024.
//

import Foundation

protocol HasGetStationSensorsParamsUseCase {
    var getStationSensorsParamsUseCase: GetStationSensorsParamsUseCaseProtocol { get }
}

protocol GetStationSensorsParamsUseCaseProtocol: Sendable {
    func get(_ stationId: Int) async throws -> [Param]
}

final class GetStationSensorsParamsUseCase: GetStationSensorsParamsUseCaseProtocol, @unchecked Sendable {
    @Injected(\.giosApiRepository) private var giosApiRepository
    @Injected(\.stationSensorsParamsNetworkMapper) private var stationSensorsParamsNetworkMapper
    
    func get(_ stationId: Int) async throws -> [Param] {
        try await giosApiRepository.fetch(
            mapper: stationSensorsParamsNetworkMapper,
            endpoint: Endpoint.Sensors.get(stationId),
            source: .cacheIfPossible
        )
    }
}
