//
//  PaginationFetchingUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/10/2025.
//

import Foundation

protocol PaginationFetchingUseCaseProtocol: Actor, Sendable {
    associatedtype DomainModel: Sendable
    associatedtype Parameters
    
    typealias PageStream = (pageContent: [DomainModel], areMorePages: Bool)
    
    func fetchNextPage() async throws
    func refresh() async throws
    
    func getStream() async -> AsyncStream<PageStream>
    func setParameters(_ parameters: Parameters) async
}
