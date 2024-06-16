//
//  Location.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import CoreLocation
import Combine

protocol HasLocationRespository {
    var locationRespository: LocationRespositoryProtocol { get }
}

protocol LocationRespositoryProtocol: AnyObject, Sendable {
    var isLocationServicesEnabled: Bool { get async }
    
    func requestLocationOnce() async throws -> Location?
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
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    init(userLocationDataSource: UserLocationDataSourceProtocol) {
        self.userLocationDataSource = userLocationDataSource
    }
    
    // MARK: Methods
    
    func requestLocationOnce() async throws -> Location? {
        var continuation: CheckedContinuation<Location, Error>?
        
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
            } receiveValue: { location in
                continuation?.resume(returning: location)
            }
            .store(in: &cancellables)
        
        return try await withCheckedThrowingContinuation { checkedContinuation in
            continuation = checkedContinuation
            requestLocation()
        }
    }
    
    // MARK: Private methods
    
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
