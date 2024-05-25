//
//  StationsListViewModel+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

extension StationsListViewModel {
    private struct GetStationsUseCase: GetStationsUseCaseProtocol {
        func getStations() async throws -> [Station] {
            [Station.previewDummy()]
        }
    }
    
    nonisolated(unsafe) static let previewDummy = StationsListViewModel(getStationsUseCase: GetStationsUseCase())
}
