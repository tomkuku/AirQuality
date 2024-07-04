//
//  UserLocationDataSourceTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/06/2024.
//

import XCTest
import CoreLocation

@testable import AirQuality

final class UserLocationDataSourceTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: UserLocationDataSource!
    private var locationManagerSpy: CLLocationManagerSpy!
    private var locationManagerFake: CLLocationManager!
        
    override func setUp() {
        super.setUp()
        
        locationManagerSpy = CLLocationManagerSpy()
        
        locationManagerFake = CLLocationManager()
        
        sut = UserLocationDataSource(locationManager: locationManagerSpy)
        
        locationManagerSpy.events.removeAll()
    }
    
    override func tearDown() {
        super.tearDown()
        
        DependenciesContainerManager.container = appDependencies
    }
    
    func testInitalize() {
        // When
        sut = UserLocationDataSource(locationManager: locationManagerSpy)
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [
            .desiredAccuracyDidSet(kCLLocationAccuracyBest),
            .delegateDidSet(sut)
        ])
    }
    
    func testRequestLocation() {
        // When
        sut.requestLocation()
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [.requestLocation])
    }
    
    func testStartUpdatingLocation() {
        // When
        sut.startUpdatingLocation()
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [.startUpdatingLocation])
    }
    
    func testStopUpdatingLocation() {
        // When
        sut.stopUpdatingLocation()
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [.stopUpdatingLocation])
    }
    
    func testRequestWhenInUseAuthorization() {
        // When
        sut.requestWhenInUseAuthorization()
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [.requestWhenInUseAuthorization])
    }
    
    func testLocationServicesEnabled() {
        // Given
        locationManagerSpy.locationServicesEnabledReturnValue = true
        
        // When
        let result = sut.locationServicesEnabled
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testAuthorizationStatus() {
        // Given
        locationManagerSpy.authorizationStatusReturnValue = .restricted
        
        // When
        let result = sut.authorizationStatus
        
        // Then
        XCTAssertEqual(result, .restricted)
    }
    
    func testLocationManagerDidUpdateLocations() {
        // Given
        let locations = [CLLocation(latitude: 1, longitude: 1), CLLocation(latitude: 2, longitude: 2)]
        
        var location: CLLocation?
        
        sut
            .locationPublisher
            .sink {
                guard case .failure = $0 else { return }
                XCTFail("Publisher should not publish any error!")
            } receiveValue: {
                location = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.locationManager(locationManagerFake, didUpdateLocations: locations)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(location, locations.first)
    }
    
        func testLocationManagerDidFailWithError() {
            // Given
            var error: Error?
            
            sut
                .locationPublisher
                .sink {
                    guard case .failure(let failureError) = $0 else { return }
                    error = failureError
                    self.expectation.fulfill()
                } receiveValue: { _ in
                    XCTFail("Publisher should not publish any value!")
                }
                .store(in: &cancellables)
    
            // When
            sut.locationManager(locationManagerFake, didFailWithError: ErrorDummy())
    
            // Then
            wait(for: [expectation], timeout: 2.0)
            
            XCTAssertTrue(error is ErrorDummy)
        }
    
    func testLocationManagerDidChangeAuthorization() {
        // Given
        var status: CLAuthorizationStatus?
        
        sut
            .authorizationStatusPublisher
            .sink {
                guard case .failure = $0 else { return }
                XCTFail("Publisher should not publish any error!")
            } receiveValue: {
                status = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.locationManager(locationManagerFake, didChangeAuthorization: .restricted)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(status, .restricted)
    }
}
