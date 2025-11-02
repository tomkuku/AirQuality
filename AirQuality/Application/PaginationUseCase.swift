//
//  PaginationFetchingUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/10/2025.
//

import Foundation

protocol PaginationFetchingUseCaseParameters: Equatable {
    
}

protocol PaginationFetchingUseCaseProtocol: Actor, Sendable {
    associatedtype DomainModel: Sendable
    associatedtype Parameters: PaginationFetchingUseCaseParameters
    
    var parameters: Parameters { get set }
    
    func fetchNextPage() async throws
    func refresh() async throws
    
    func getStream() async -> AsyncStream<[DomainModel]>
}
