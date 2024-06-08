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
    
    @Published private(set) var annotations: [Model.StationAnnotation] = []
    
    // MARK: Private properties
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    private let observeStationUseCase: ObserveStationUseCaseProtocol
    private let deleteStationFromObservedListUseCase: DeleteStationFromObservedListUseCaseProtocol
    private let getObservedStationsUseCase: GetObservedStationsUseCaseProtocol
    
    private var fetchedStations: [Station] = []
    
    // MARK: Lifecycle
    
    init(
        getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase(),
        observeStationUseCase: ObserveStationUseCaseProtocol = ObserveStationUseCase(),
        deleteStationFromObservedListUseCase: DeleteStationFromObservedListUseCaseProtocol = DeleteStationFromObservedListUseCase(),
        getObservedStationsUseCase: GetObservedStationsUseCaseProtocol = GetObservedStationsUseCase()
    ) {
        self.getStationsUseCase = getStationsUseCase
        self.observeStationUseCase = observeStationUseCase
        self.deleteStationFromObservedListUseCase = deleteStationFromObservedListUseCase
        self.getObservedStationsUseCase = getObservedStationsUseCase
        
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
                try await self.observeStationUseCase.observe(station: station)
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
                try await self.deleteStationFromObservedListUseCase.delete(station: station)
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
