//
//  UserLocationRepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/06/2024.
//

import XCTest
import CoreLocation

@testable import AirQuality

final class UserLocationRepositoryTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: LocationRespository!
    
    private var userLocationDataSourceSpy: UserLocationDataSourceSpy!
    
    override func setUp() {
        super.setUp()
        
        userLocationDataSourceSpy = UserLocationDataSourceSpy()
        
        sut = LocationRespository(userLocationDataSource: userLocationDataSourceSpy)
    }
    
    func testIsLocationServicesEnabled() async {
        // Given
        userLocationDataSourceSpy.locationServicesEnabledReturnValue = true
        
        // When
        let result = await sut.isLocationServicesEnabled
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testRequestLocationOnceWhenAuthorizationStatusIsNotDetermined() async throws {
        // Given
        let location = CLLocation(latitude: 1, longitude: 1)
        
        userLocationDataSourceSpy.authorizationStatusReturnValue = .notDetermined
        
        userLocationDataSourceSpy.requestWhenInUseAuthorizationHandler = {
            self.userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
            self.userLocationDataSourceSpy.autchorizationStatusSubject.send(.authorizedWhenInUse)
        }
        
        userLocationDataSourceSpy.requestLocationHandler = {
            self.userLocationDataSourceSpy.locationSubject.send(location)
        }
        
        // When
        let locationCoordiates = try await sut.requestLocationOnce()
        
        // Then
        XCTAssertEqual(locationCoordiates?.coordinate.latitude, 1)
        XCTAssertEqual(locationCoordiates?.coordinate.longitude, 1)
        XCTAssertEqual(userLocationDataSourceSpy.events, [
            .getAuthorizationStatusPublisher,
            .getLocationPublisher,
            .getAuthorizationStatus,
            .requestWhenInUseAuthorization,
            .getAuthorizationStatus,
            .requestLocation
        ])
    }
    
    func testRequestLocationOnceWhenAuthorizationStatusIsWhenInUse() async throws {
        // Given
        let location = CLLocation(latitude: 1, longitude: 1)
        
        userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
        
        userLocationDataSourceSpy.requestLocationHandler = {
            /// Simulate ask location request.
            self.userLocationDataSourceSpy.locationSubject.send(location)
        }
        
        // When
        let locationCoordiates = try await sut.requestLocationOnce()
        
        // Then
        XCTAssertEqual(locationCoordiates?.coordinate.latitude, 1)
        XCTAssertEqual(locationCoordiates?.coordinate.longitude, 1)
        XCTAssertEqual(userLocationDataSourceSpy.events, [
            .getAuthorizationStatusPublisher,
            .getLocationPublisher,
            .getAuthorizationStatus,
            .requestLocation
        ])
    }
    
    func testRequestLocationOnceWhenFailure() async {
        // Given
        userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
        
        userLocationDataSourceSpy.requestLocationHandler = {
            self.userLocationDataSourceSpy.locationSubject.send(completion: .failure(ErrorDummy()))
        }
        
        do {
            // When
            let locationCoordiates = try await sut.requestLocationOnce()
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(userLocationDataSourceSpy.events, [
                .getAuthorizationStatusPublisher,
                .getLocationPublisher,
                .getAuthorizationStatus,
                .requestLocation
            ])
        }
    }
}
