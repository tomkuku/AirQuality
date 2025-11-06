//
//  GIOSApiRepository.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation
import Combine

protocol HasGIOSApiV1Repository {
    var giosApiV1Repository: GIOSApiV1RepositoryProtocol { get }
}

protocol GIOSApiV1RepositoryProtocol: Sendable {
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        mappingInputParameters: T.InputParameters
    ) async throws -> (output: T.DomainModel, totalPages: Int) where T: NetworkMapperProtocol
    
    func fetchAllStations() async throws -> [Station]
}

extension GIOSApiV1RepositoryProtocol {
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, T.InputParameters == Void {
        try await fetch(mapper: mapper, endpoint: endpoint, mappingInputParameters: ()).output
    }
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        mappingInputParameters: T.InputParameters
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        try await fetch(mapper: mapper, endpoint: endpoint, mappingInputParameters: mappingInputParameters).output
    }
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest
    ) async throws -> (output: T.DomainModel, totalPages: Int) where T: NetworkMapperProtocol, T.InputParameters == Void {
        try await fetch(mapper: mapper, endpoint: endpoint, mappingInputParameters: ())
    }
}

actor GIOSApiV1Repository: GIOSApiV1RepositoryProtocol {
    
    // MARK: Private Properties
    
    private let jsonDecoder: JSONDecoder
    private let httpDataSource: HTTPDataSourceProtocol
    
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    @Injected(\.stationsNetworkMapper) private var stationsNetworkMapper
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.httpDataSource = httpDataSource
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: Methods
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        mappingInputParameters: T.InputParameters
    ) async throws -> (output: T.DomainModel, totalPages: Int) where T: NetworkMapperProtocol {
        let data = try await httpDataSource.requestData(endpoint)
        let decodedResponse = try jsonDecoder.decode(GIOSApiV1.Response<T.DTOModel>.self, from: data)
        let domainModel = try mapper.map(decodedResponse.content, using: mappingInputParameters)
        return (domainModel, decodedResponse.totalPages)
    }
    
    func fetchAllStations() async throws -> [Station] {
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
