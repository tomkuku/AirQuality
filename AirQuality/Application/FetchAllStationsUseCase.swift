//
//  GetStationsUseCase.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire
import UIKit

protocol HasFetchAllStationsUseCase {
    var fetchAllStationsUseCase: FetchAllStationsUseCaseProtocol { get }
}

protocol FetchAllStationsUseCaseProtocol: Sendable {
    func fetch() async throws -> [Station]
}

final class FetchAllStationsUseCase: FetchAllStationsUseCaseProtocol {
    private var giosApiV1Repository: GIOSApiV1RepositoryProtocol {
        Injected(\.giosApiV1Repository).wrappedValue
    }
    
    private var stationsNetworkMapper: any StationsNetworkMapperProtocol {
        Injected(\.stationsNetworkMapper).wrappedValue
    }
    
    init() { }
    
    func fetch() async throws -> [Station] {
        var areMorePages = true
        var allStations: [Station] = []
        var page = 0
        
        repeat {
            let endpoint = Endpoint.Stations.get(page: page, size: 300)
            
            let response: (output: [Station], totalPages: Int) = try await giosApiV1Repository.fetch(
                mapper: stationsNetworkMapper,
                endpoint: endpoint
            )
            
            allStations.append(contentsOf: response.output)
            
            areMorePages = page < max((response.totalPages - 1), 0)
            page += 1
        } while areMorePages
        
        return allStations
    }
}
