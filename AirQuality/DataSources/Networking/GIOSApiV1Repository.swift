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
}
