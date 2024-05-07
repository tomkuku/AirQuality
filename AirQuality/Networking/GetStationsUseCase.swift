//
//  GetStationsUseCase.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire

public final class GetStationsUseCase {
    @Injected(\.giosApiRepository) private var giosApiRepository
    
    public init() { }
    
    public func getAllStations() async throws -> [Station] {
        try await giosApiRepository.fetch(
            mapperType: StationsNetworkMapper.self,
            endpoint: Endpoint.Stations.get,
            contentContainerName: "Lista stacji pomiarowych"
        )
    }
}
