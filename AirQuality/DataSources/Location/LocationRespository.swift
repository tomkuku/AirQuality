//
//  Location.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import CoreLocation
import Combine

enum UserLocationServicesError: Error {
    case disabled
    case authorizationRestricted
    case authorizationDenied
}

protocol HasLocationRespository {
    var locationRespository: LocationRespositoryProtocol { get }
}

protocol LocationRespositoryProtocol: AnyObject, Sendable {
    var isLocationServicesEnabled: Bool { get async }
    
    func requestLocationOnce() async throws -> Location?
    
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error>
    
    func checkLocationServicesAvailability() async throws
}

actor LocationRespository: LocationRespositoryProtocol {
    
    // MARK: Properties
    
    var isLocationServicesEnabled: Bool {
        get async {
            userLocationDataSource.locationServicesEnabled
        }
    }
    
    // MARK: Private properties
    
    private let userLocationDataSource: UserLocationDataSourceProtocol
    private var streamLocationCancellables = [UUID: Set<AnyCancellable>]()
    
    // MARK: Lifecycle
    
    init(userLocationDataSource: UserLocationDataSourceProtocol) {
        self.userLocationDataSource = userLocationDataSource
    }
    
    // MARK: Methods
    
    func checkLocationServicesAvailability() async throws {
        guard userLocationDataSource.locationServicesEnabled else {
            throw UserLocationServicesError.disabled
        }
        
        switch userLocationDataSource.authorizationStatus {
        case .restricted:
            throw UserLocationServicesError.authorizationRestricted
        case .denied:
            throw UserLocationServicesError.authorizationDenied
        default:
            break
        }
    }
    
    func requestLocationOnce() async throws -> Location? {
        var continuation: CheckedContinuation<Location, Error>?
        var cancellables = Set<AnyCancellable>()
        
        userLocationDataSource
            .authorizationStatusPublisher
            .asyncSink(receiveValue: { [weak self] _ in
                await self?.requestLocation()
            })
            .store(in: &cancellables)
        
        userLocationDataSource
            .locationPublisher
            .sink {
                guard case .failure(let error) = $0 else { return }
                
                continuation?.resume(throwing: error)
                cancellables.removeAll()
            } receiveValue: { location in
                continuation?.resume(returning: location)
                cancellables.removeAll()
                continuation = nil
            }
            .store(in: &cancellables)
        
        return try await withCheckedThrowingContinuation { checkedContinuation in
            continuation = checkedContinuation
            requestLocation()
        }
    }
        
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error> {
        var continuation: AsyncThrowingStream<Location, Error>.Continuation?
        var cancellables = Set<AnyCancellable>()
        
        userLocationDataSource
            .authorizationStatusPublisher
            .asyncSink(receiveValue: { [weak self] _ in
                await self?.requestLocation()
            })
            .store(in: &cancellables)
        
        userLocationDataSource
            .locationPublisher
            .sink {
                guard case .failure(let error) = $0 else { return }
                
                continuation?.finish(throwing: error)
            } receiveValue: { location in
                continuation?.yield(location)
            }
            .store(in: &cancellables)
        
        let wasStreamLocationCancellablesEmpty = isCancellablesEmpty()
        let uuid = addStreamLocationCancellables(&cancellables)
        
        let completion: @Sendable (isolated LocationRespository) -> () = { selfActor in
            selfActor.removeStreamLocationCancellables(for: uuid)
            
            if selfActor.streamLocationCancellables.isEmpty {
                selfActor.stopUpdatingLocation()
            }
        }
        
        finishClosure = {
            Task { [weak self] in
                guard let self else { return }
                await completion(self)
            }
        }
        
        return AsyncThrowingStream {
            continuation = $0
            
            if wasStreamLocationCancellablesEmpty {
                userLocationDataSource.startUpdatingLocation()
                userLocationDataSource.requestWhenInUseAuthorization()
            }
        }
    }
    
    // MARK: Private methods
    
    private func addStreamLocationCancellables(_ cancellables: inout Set<AnyCancellable>) -> UUID {
        let uuid = UUID()
        self.streamLocationCancellables[uuid] = cancellables
        return uuid
    }
    
    private func removeStreamLocationCancellables(for uuid: UUID) {
        streamLocationCancellables.removeValue(forKey: uuid)
    }
    
    private func isCancellablesEmpty() -> Bool {
        streamLocationCancellables.isEmpty
    }
    
    private func stopUpdatingLocation() {
        userLocationDataSource.stopUpdatingLocation()
    }
    
    private func requestLocation() {
        switch userLocationDataSource.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            userLocationDataSource.requestLocation()
        case .notDetermined:
            userLocationDataSource.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}
