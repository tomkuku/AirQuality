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
    @Injected(\.giosApiRepository) private var giosApiRepository
    @Injected(\.stationsNetworkMapper) private var stationsNetworkMapper
    
    let giosApiRepository2 = (UIApplication.shared.delegate as? AppDelegate)?.dependenciesContainer
    
    init() { }
    
    func fetch() async throws -> [Station] {
        try await giosApiRepository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get,
            source: .cacheIfPossible
        )
    }
}
