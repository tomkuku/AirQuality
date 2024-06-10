//
//  GetStationsUseCase.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire

protocol HasGetStationsUseCase {
    var getStationsUseCase: GetStationsUseCaseProtocol { get }
}

protocol GetStationsUseCaseProtocol: Sendable {
    func getStations() async throws -> [Station]
}

final class GetStationsUseCase: GetStationsUseCaseProtocol, @unchecked Sendable {
    @Injected(\.giosApiRepository) private var giosApiRepository
    
    private let stationsNetworkMapper: any StationsNetworkMapperProtocol
    
    init(
        stationsNetworkMapper: any StationsNetworkMapperProtocol = StationsNetworkMapper()
    ) {
        self.stationsNetworkMapper = stationsNetworkMapper
    }
    
    func getStations() async throws -> [Station] {
        try await giosApiRepository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get
        )
    }
}
