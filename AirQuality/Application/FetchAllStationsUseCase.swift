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
    private var giosApiRepository: GIOSApiRepositoryProtocol {
        Injected(\.giosApiRepository).wrappedValue
    }
    
    private var stationsNetworkMapper: any StationsNetworkMapperProtocol {
        Injected(\.stationsNetworkMapper).wrappedValue
    }
    
    init() { }
    
    func fetch() async throws -> [Station] {
        try await giosApiRepository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get,
            source: .cacheIfPossible
        )
    }
}
