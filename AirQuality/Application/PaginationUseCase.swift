//
//  PaginationFetchingUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/10/2025.
//

import Foundation

protocol PaginationFetchingUseCaseProtocol: Sendable {
    associatedtype DomainModel: Sendable
    associatedtype Parameters: Sendable
    
    typealias PageStream = (pageContent: [DomainModel], areMorePages: Bool)
    
    func fetchNextPage() async throws
    func refresh() async throws
    
    func getStream(getStreamCompletion: @escaping @Sendable () -> ()) async -> AsyncStream<PageStream>
    func setParameters(_ parameters: Parameters) async
}
