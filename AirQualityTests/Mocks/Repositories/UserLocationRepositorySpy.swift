//
//  UserLocationRepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import Foundation
import Combine
import XCTest

@testable import AirQuality

actor UserLocationRepositorySpy: LocationRespositoryProtocol {
    func streamLocation(finishClosure: inout (@Sendable () -> ())?) async -> AsyncThrowingStream<AirQuality.Location, any Error> {
        fatalError("streamLocation requires an implementation!")
    }
    
    func checkLocationServicesAvailability() async throws { }
    
    enum Event {
        case requestLocationOnce
        case isLocationServicesEnabled
    }
    
    var events: [Event] = []
    
    var isLocationServicesEnabled: Bool {
        events.append(.isLocationServicesEnabled)
        return isLocationServicesEnabledReturnValue
    }
    
    var isLocationServicesEnabledReturnValue = false
    
    var requestLocationOnceResult: Result<Location?, Error>?
    
    func setRequestLocationOnceResult(_ result: Result<Location?, Error>) {
        requestLocationOnceResult = result
    }
    
    func requestLocationOnce() async throws -> Location? {
        events.append(.requestLocationOnce)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let requestLocationOnceResult else {
                XCTFail("requestLocationOnce result is not set!")
                return
            }
            
            continuation.resume(with: requestLocationOnceResult)
        }
    }
}
