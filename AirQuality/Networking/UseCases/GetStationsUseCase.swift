//
//  GetStationsUseCase.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire

protocol GetStationsUseCaseProtocol: Sendable {
    func getAllStations() async throws -> [Station]
}

final class GetStationsUseCase: GetStationsUseCaseProtocol {
    @Injected(\.giosApiRepository) private var giosApiRepository
    
    init() { }
    
    func getAllStations() async throws -> [Station] {
        try await giosApiRepository.fetch(
            mapperType: StationsNetworkMapper.self,
            endpoint: Endpoint.Stations.get,
            contentContainerName: "Lista stacji pomiarowych"
        )
    }
}
