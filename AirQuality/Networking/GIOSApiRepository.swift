//
//  GIOSApiRepository.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation

protocol HasGIOSApiRepository {
    var giosApiRepository: GIOSApiRepositoryProtocol { get }
}

protocol GIOSApiRepositoryProtocol: Sendable {
    func fetch<T, R>(
        mapperType: T.Type,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: MapperProtocol, R: HTTPRequest
}

final class GIOSApiRepository: GIOSApiRepositoryProtocol {
    
    // MARK: Private Properties
    
    private let decoder = JSONDecoder()
    private let httpDataSource: HTTPDataSourceProtocol
    
    init(httpDataSource: HTTPDataSourceProtocol) {
        self.httpDataSource = httpDataSource
    }
    
    // MARK: Methods
    
    func fetch<T, R>(
        mapperType: T.Type,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: MapperProtocol, R: HTTPRequest {
        let mapper = T()
        let request = try endpoint.asURLRequest()
        
        let data = try await httpDataSource.requestData(request)
        
        do {
            let container = try decoder.decode(GIOSApiResponse.self, from: data)
            let networkModelObjects: T.NetworkModel = try container.getValue(for: contentContainerName)
            return try mapper.map(networkModelObjects)
        } catch {
            throw error
        }
    }
}
