//
//  StationsListViewPreviewMock.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

enum StationsListViewPreviewMock {
    struct GetStationsUseCase: GetStationsUseCaseProtocol {
        func getAllStations() async throws -> [Station] {
            [Station.previewMock()]
        }
    }
    
    nonisolated(unsafe) static let viewModel = StationsListViewModel(getStationsUseCase: GetStationsUseCase())
}
