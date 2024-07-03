//
//  ParamsViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/07/2024.
//

import Foundation

final class ParamsViewModel: BaseViewModel {
    
    // MARK: Properties
    
    @Published private(set) var params: [Param]?
    
    // MARK: Private properties
    
    @Injected(\.getStationSensorsParamsUseCase) private var getStationSensorsParamsUseCase
    
    private let station: Station
    private var task: Task<Void, Never>?
    
    // MARK: Lifecycle
    
    init(station: Station) {
        self.station = station
        super.init()
    }
    
    deinit {
        task?.cancel()
    }
    
    // MARK: Methods
    
    func fetchParamsMeasuredByStation() {
        task = Task.detached { [weak self] in
            guard let self else { return }
            
            do {
                let params = try await self.getStationSensorsParamsUseCase.get(self.station.id)
                
                await MainActor.run {
                    self.isLoading = false
                    self.params = params
                }
            } catch {
                Logger.error("Fetching params measured by station failed with error: \(error)")
                
                await MainActor.run {
                    self.errorSubject.send(error)
                }
            }
        }
    }
}
