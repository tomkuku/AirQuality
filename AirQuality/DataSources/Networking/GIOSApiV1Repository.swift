//
//  GIOSApiRepository.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation

protocol HasGIOSApiV1Repository {
    var giosApiV1Repository: GIOSApiV1RepositoryProtocol { get }
}

protocol GIOSApiV1RepositoryProtocol: Sendable {
    func fetch<T, R>(
        mapper: T,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest
}

final class GIOSApiV1Repository: GIOSApiV1RepositoryProtocol {
    
    // MARK: Private Properties
    
    private let decoder = JSONDecoder()
    private let httpDataSource: HTTPDataSourceProtocol
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol
    ) {
        self.httpDataSource = httpDataSource
    }
    
    // MARK: Methods
    
    func fetch<T, R>(
        mapper: T,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest {
        let mapper = T()
        let request = try endpoint.asURLRequest()
        
        let data = try await httpDataSource.requestData(request)
        
        do {
            let container = try decoder.decode(GIOSApiV1Response.self, from: data)
            let networkModelObjects: T.DTOModel = try container.getValue(for: contentContainerName)
            return try mapper.map(networkModelObjects)
        } catch {
            throw error
        }
    }
}
