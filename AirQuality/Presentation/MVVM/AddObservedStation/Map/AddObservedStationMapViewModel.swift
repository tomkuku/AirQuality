//
//  AddObservedStationMapViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import Combine

@MainActor
final class AddObservedStationMapViewModel: BaseViewModel {
    
    typealias Model = AddObservedStationMapModel
    
    // MARK: Properties
    
    @Injected(\.addObservedStationUseCase) private var addObservedStationUseCase
    @Injected(\.deleteObservedStationUseCase) private var deleteObservedStationUseCase
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    @Injected(\.getStationsUseCase) private var getStationsUseCase
    
    @Published private(set) var annotations: [Model.StationAnnotation] = []
    
    // MARK: Private properties
    
    private var fetchedStations: [Station] = []
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        isLoading = true
        receiveObservedStationsStream()
    }
    
    // MARK: Methods
    
    func fetchStations() {
        isLoading(true, objectWillChnage: true)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                async let fetchedStations = getStationsUseCase.getStations()
                async let observedStations = getObservedStationsUseCase.fetchedStations()
                
                let result = try await (fetchedStations, observedStations)
                
                self.fetchedStations = result.0
                
                isLoading(false, objectWillChnage: false)
                
                createStationAnnotations(with: result.1)
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func addStationToObserved(_ station: Station) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.addObservedStationUseCase.add(station: station)
                self.toastSubject.send(Toast(body: "Stacja została dodana do obserwowanych"))
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func deletedStationFromObservedList(_ station: Station) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.deleteObservedStationUseCase.delete(station: station)
                self.toastSubject.send(Toast(body: "Stacja została usunięta z listy obserwowanych"))
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    // MARK: Private methods
    
    private func createStationAnnotations(with observedStations: [Station]) {
        annotations = fetchedStations.map { station in
            let isStationObserved = observedStations.contains(station)
            return Model.StationAnnotation(station: station, isStationObserved: isStationObserved)
        }
    }
    
    private func receiveObservedStationsStream() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                for try await observedSations in getObservedStationsUseCase.createNewStream() where !fetchedStations.isEmpty {
                    self.createStationAnnotations(with: observedSations)
                }
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
}
