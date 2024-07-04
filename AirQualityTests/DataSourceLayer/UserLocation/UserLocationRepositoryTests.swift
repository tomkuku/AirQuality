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
    private var finishClosure: (@Sendable () -> ())?
    private var locations: [CLLocation]!
    private var error: Error?
    
    override func setUp() {
        super.setUp()
        
        userLocationDataSourceSpy = UserLocationDataSourceSpy()
        
        locations = []
        
        sut = LocationRespository(userLocationDataSource: userLocationDataSourceSpy)
    }
    
    // MARK: isLocationServicesEnabled
    
    func testIsLocationServicesEnabled() async {
        // Given
        userLocationDataSourceSpy.locationServicesEnabledReturnValue = true
        
        // When
        let result = await sut.isLocationServicesEnabled
        
        // Then
        XCTAssertTrue(result)
    }
    
    // MARK: requestLocationOnce
    
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
            _ = try await sut.requestLocationOnce()
            XCTFail("requestLocationOnce should have thrown error!")
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
    
    // MARK: requestLocationOnce
    
    func testStreamLocationWhenAuthorizedStatusIsWhenInUse() throws {
        // Given
        let location1 = CLLocation(latitude: 1, longitude: 1)
        let location2 = CLLocation(latitude: 2, longitude: 2)
        let location3 = CLLocation(latitude: 3, longitude: 3)
        
        userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
        
        userLocationDataSourceSpy.requestLocationHandler = {
            [location1, location2, location3].forEach {
                self.userLocationDataSourceSpy.locationSubject.send($0)
            }
        }
        
        expectation.expectedFulfillmentCount = 3
        
        // When
        Task {
            for try await location in await sut.streamLocation(finishClosure: &self.finishClosure) {
                locations.append(location)
                self.expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(locations.first, location1)
        XCTAssertEqual(locations.last, location3)
        XCTAssertEqual(userLocationDataSourceSpy.events, [
            .getAuthorizationStatusPublisher,
            .getLocationPublisher,
            .startUpdatingLocation,
            .getAuthorizationStatus,
            .requestLocation
        ])
        
        // Given
        userLocationDataSourceSpy.events.removeAll()
        
        expectation = XCTestExpectation()
        userLocationDataSourceSpy.expectation = expectation
        
        // When
        finishClosure?()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(userLocationDataSourceSpy.events, [.stopUpdatingLocation])
    }
    
    func testStreamLocationWhenAuthorizedStatusIsNotDetermined() throws {
        // Given
        let location1 = CLLocation(latitude: 1, longitude: 1)
        let location2 = CLLocation(latitude: 2, longitude: 2)
        let location3 = CLLocation(latitude: 3, longitude: 3)
        
        userLocationDataSourceSpy.authorizationStatusReturnValue = .notDetermined
        
        userLocationDataSourceSpy.requestWhenInUseAuthorizationHandler = {
            self.userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
            self.userLocationDataSourceSpy.autchorizationStatusSubject.send(.authorizedWhenInUse)
        }
        
        userLocationDataSourceSpy.requestLocationHandler = {
            [location1, location2, location3].forEach {
                self.userLocationDataSourceSpy.locationSubject.send($0)
            }
        }
        
        expectation.expectedFulfillmentCount = 3
        
        // When
        try newTask {
            for try await location in await self.sut.streamLocation(finishClosure: &self.finishClosure) {
                self.locations.append(location)
                self.expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(locations.first, location1)
        XCTAssertEqual(locations.last, location3)
        XCTAssertEqual(userLocationDataSourceSpy.events, [
            .getAuthorizationStatusPublisher,
            .getLocationPublisher,
            .startUpdatingLocation,
            .getAuthorizationStatus,
            .requestWhenInUseAuthorization,
            .getAuthorizationStatus,
            .requestLocation
        ])
    }
    
    func testStreamLocationWhenFailure() throws {
        // Given
        userLocationDataSourceSpy.authorizationStatusReturnValue = .authorizedWhenInUse
        
        userLocationDataSourceSpy.requestLocationHandler = {
            self.userLocationDataSourceSpy.locationSubject.send(completion: .failure(ErrorDummy()))
        }
        
        newTask {
            // When
            for try await _ in await self.sut.streamLocation(finishClosure: &self.finishClosure) {
                XCTFail("Location stream should not emit any value!")
            }
            
            XCTFail("streamLocation should have thrown error!")
        } onError: {
            self.error = $0
            self.expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(error is ErrorDummy)
        XCTAssertEqual(Set(userLocationDataSourceSpy.events), Set([
            .getLocationPublisher,
            .getAuthorizationStatus,
            .startUpdatingLocation,
            .requestLocation,
            .getAuthorizationStatusPublisher
        ]))
    }
}
