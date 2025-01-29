//
//  GetUserLocationUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 30/06/2024.
//

import Foundation
import class CoreLocation.CLLocation

final class GetUserLocationUseCasePreviewDummy: GetUserLocationUseCaseProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var locationStreamLocationRange: (latitudeRange: ClosedRange<Double>, longitudeRange: ClosedRange<Double>)?
    
    nonisolated(unsafe) static var checkLocationServicesAvailabilityError: UserLocationServicesError?
    
    private var task: Task<Void, Never>?
    
    deinit {
        task?.cancel()
    }
    
    func checkLocationServicesAvailability() async throws { 
        guard let checkLocationServicesAvailabilityError = Self.checkLocationServicesAvailabilityError else {
            return
        }
        
        throw checkLocationServicesAvailabilityError
    }
    
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error> {
        AsyncThrowingStream<Location, Error> { continuation in
            task = Task {
                guard let locationStreamLocationRange = Self.locationStreamLocationRange else {
                    Logger.error("locationStreamLocation is nil!")
                    return
                }
                
                while true {
                    let latitude = Double.random(in: locationStreamLocationRange.latitudeRange)
                    let longitude = Double.random(in: locationStreamLocationRange.longitudeRange)
                    
                    continuation.yield(CLLocation(latitude: latitude, longitude: longitude))
                    
                    do {
                        try await Task.sleep(for: .seconds(4))
                    } catch {
                        Logger.error("\(error)")
                    }
                }
            }
        }
    }
}
