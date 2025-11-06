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
    private var giosApiV1Repository: GIOSApiV1RepositoryProtocol {
        Injected(\.giosApiV1Repository).wrappedValue
    }
    
    init() { }
    
    func fetch() async throws -> [Station] {
        try await giosApiV1Repository.fetchAllStations()
    }
}
