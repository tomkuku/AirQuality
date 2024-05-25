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

final class GetStationsUseCase: GetStationsUseCaseProtocol, @unchecked Sendable {
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    
    func getAllStations() async throws -> [Station] {
        try await giosApiV1Repository.fetch(
            mapperType: StationsNetworkMapper.self,
            endpoint: Endpoint.Stations.get,
            contentContainerName: "Lista stacji pomiarowych"
        )
    }
}
