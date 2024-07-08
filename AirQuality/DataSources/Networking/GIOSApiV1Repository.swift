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
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol
}

actor GIOSApiV1Repository: GIOSApiV1RepositoryProtocol {
    
    // MARK: Private Properties
    
    private let jsonDecoder: JSONDecoder
    private let httpDataSource: HTTPDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        let data = try await httpDataSource.requestData(endpoint)
        let decodableObject = try jsonDecoder.decode(T.DTOModel.self, from: data)
        return try mapper.map(decodableObject)
    }
}
