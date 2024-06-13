//
//  LocationDataSourceTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/06/2024.
//

import XCTest
import CoreLocation

@testable import AirQuality

final class LocationDataSourceTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: LocationDataSource!
    private var locationManagerSpy: CLLocationManagerSpy!
    private var notificationCenterSpy: NotificationCenterSpy!
    private var locationManagerFake: CLLocationManager!
        
    override func setUp() {
        super.setUp()
        
        locationManagerSpy = CLLocationManagerSpy()
        notificationCenterSpy = NotificationCenterSpy()
        
        locationManagerFake = CLLocationManager()
        
        sut = LocationDataSource(locationManager: locationManagerSpy)
        
        dependenciesContainerDummy[\.notificationCenter] = notificationCenterSpy
        
        locationManagerSpy.events.removeAll()
    }
    
    override func tearDown() {
        super.tearDown()
        
        DependenciesContainerManager.container = appDependencies
    }
    
    func testInitalize() {
        // When
        sut = LocationDataSource(locationManager: locationManagerSpy)
        
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
    
    func testRequestWhenInUseAuthorization() {
        // When
        sut.requestWhenInUseAuthorization()
        
        // Then
        XCTAssertEqual(locationManagerSpy.events, [.requestWhenInUseAuthorization])
    }
    
    func testIsLocationServicesEnabled() {
        // Given
        locationManagerSpy.locationServicesEnabledReturnValue = true
        
        // When
        let result = sut.isLocationServicesEnabled()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testGetAuthorizationStatus() {
        // Given
        locationManagerSpy.authorizationStatusReturnValue = .restricted
        
        // When
        let result = sut.getAuthorizationStatus()
        
        // Then
        XCTAssertEqual(result, .restricted)
    }
    
    func testLocationManagerDidUpdateLocations() async throws {
        // Given
        let locations = [CLLocation(latitude: 1, longitude: 1), CLLocation(latitude: 2, longitude: 2)]
        
        let task = Task { () -> CLLocation? in
            do {
                for try await location in sut.getLocationAsyncPublisher() {
                    return location
                }
            } catch {
                XCTFail("Publisher should not publish any error!")
            }
            
            return nil
        }
        
        /// Wait 0.1 to perform code in Task
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.locationManager(locationManagerFake, didUpdateLocations: locations)
        
        // Then
        let result = await task.value
        
        XCTAssertEqual(result, locations.first)
    }
    
    func testLocationManagerDidChangeAuthorization() {
        // When
        sut.locationManager(locationManagerFake, didChangeAuthorization: .authorizedAlways)
        
        // Then
        XCTAssertEqual(notificationCenterSpy.events, [.post(.locationDataSourceDidChangeAuthorization)])
    }
    
    func testLocationManagerDidFailWithError() async throws {
        // Given
        let task = Task { () -> Error? in
            do {
                for try await _ in sut.getLocationAsyncPublisher() {
                    XCTFail("Publisher should have publish error!")
                }
            } catch {
                return error
            }
            
            return nil
        }
        
        /// Wait 0.1 to perform code in Task
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        sut.locationManager(locationManagerFake, didFailWithError: ErrorDummy())
        
        // Then
        let error = await task.value
        
        XCTAssertTrue(error is ErrorDummy)
    }
}
