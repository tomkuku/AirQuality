//
//  AddObservedStationMapViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class AddObservedStationMapViewModel: BaseViewModel {
    
    typealias Model = AddObservedStationMapModel
    
    // MARK: Properties
    
    @Published private(set) var annotations: [Model.StationAnnotation] = []
    @Published private(set) var userLocation: CLLocation?
    
    private(set) lazy var theNearestStationPublisher = theNearestStationSubject.eraseToAnyPublisher()
    private(set) lazy var addedObservedStationPublisher = addedObservedStationSubject.eraseToAnyPublisher()
    private(set) lazy var deletedObservedStationPublisher = deletedObservedStationSubject.eraseToAnyPublisher()
    
    // MARK: Private properties
    
    @Injected(\.addObservedStationUseCase) private var addObservedStationUseCase
    @Injected(\.deleteObservedStationUseCase) private var deleteObservedStationUseCase
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    @Injected(\.fetchAllStationsUseCase) private var fetchAllStationsUseCase
    @Injected(\.findTheNearestStationUseCase) private var findTheNearestStationUseCase
    @Injected(\.getUserLocationUseCase) private var getUserLocationUseCase
    
    private var theNearestStationSubject = PassthroughSubject<Station, Never>()
    private var addedObservedStationSubject = PassthroughSubject<Void, Never>()
    private var deletedObservedStationSubject = PassthroughSubject<Void, Never>()
    private var fetchedStations: [Station] = []
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        isLoading = true
        receiveObservedStationsStream()
    }
    
    deinit {
        finishTrackingUserLocationClosure?()
    }
    
    private var finishTrackingUserLocationClosure: (@Sendable () -> ())?
    
    // MARK: Methods
    
    func startTrackingUserLocation() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.getUserLocationUseCase.checkLocationServicesAvailability()
                
                var finishTrackingUserLocationClosure: (@Sendable () -> ())?
                
                let stream = await self.getUserLocationUseCase.streamLocation(finishClosure: &finishTrackingUserLocationClosure)

                self.finishTrackingUserLocationClosure = consume finishTrackingUserLocationClosure
                
                for try await location in stream {
                    userLocation = location
                }
            } catch {
                Logger.error("Tracking user location failed: \(error.localizedDescription)")
                self.userLocation = nil
                self.errorSubject.send(error)
            }
        }
    }
    
    func stopTrackingUserLocation() {
        finishTrackingUserLocationClosure?()
        finishTrackingUserLocationClosure = nil
    }
    
    func fetchStations() {
        isLoading(true, objectWillChnage: true)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                async let fetchedStations = fetchAllStationsUseCase.fetch()
                async let observedStations = getObservedStationsUseCase.fetchedStations()
                
                let result = try await (fetchedStations, observedStations)
                
                self.fetchedStations = result.0
                
                isLoading(false, objectWillChnage: false)
                
                createStationAnnotations(with: result.1)
            } catch {
                Logger.error(error.localizedDescription)
                self.errorSubject.send(error)
            }
        }
    }
    
    func findTheNearestStation() {
        Task { [weak self] in
            do {
                try await self?.getUserLocationUseCase.checkLocationServicesAvailability()
                
                guard let theNearestStation = try await self?.findTheNearestStationUseCase.find() else { return }
                
                self?.theNearestStationSubject.send(theNearestStation.station)
            } catch {
                Logger.error("Finding the nearest station failed with error: \(error)")
                self?.errorSubject.send(error)
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
