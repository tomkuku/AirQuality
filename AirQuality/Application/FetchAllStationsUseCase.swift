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
        let numberOfStations = try await fetchNumberOfStations()
        
        return try await withThrowingTaskGroup(of: [Station].self) { group in
            for page in 0..<numberOfStations {
                group.addTask { [weak self] in
                    guard let self else { return [] }
                    
                    return try await self.handleFetchPage(page)
                }
            }
            
            var stations: [Station] = []
            
            for try await result in group {
                stations.append(contentsOf: result)
            }
            
            return stations
        }
    }
    
    private func handleFetchPage(_ page: Int) async throws -> [Station] {
        try await giosApiV1Repository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get(page: page, size: 100),
            contentContainerName: .stations
        )
    }
    
    private func fetchNumberOfStations() async throws -> Int {
        try await giosApiV1Repository.fetchNumberOfPages(
            endpoint: Endpoint.Stations.get(page: 1, size: 100)
        )
    }
}
