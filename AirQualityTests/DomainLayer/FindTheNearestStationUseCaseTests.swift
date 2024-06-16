//
//  FindTheNearestStationUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest
import CoreLocation

@testable import AirQuality

final class FindTheNearestStationUseCaseTests: BaseTestCase {
    
    private var sut: FindTheNearestStationUseCase!
    
    private var userLocationRepositorySpy: UserLocationRepositorySpy!
    private var giosApiRepositorySpy: GIOSApiRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        userLocationRepositorySpy = UserLocationRepositorySpy()
        giosApiRepositorySpy = GIOSApiRepositorySpy()
        
        sut = FindTheNearestStationUseCase()
        
        dependenciesContainerDummy[\.locationRespository] = userLocationRepositorySpy
        dependenciesContainerDummy[\.giosApiRepository] = giosApiRepositorySpy
        dependenciesContainerDummy[\.stationsNetworkMapper] = StationsNetworkMapperFake()
    }
    
    func testFind() async throws {
        // Given
        let fetchResultStations = [
            Station.dummy(id: 1, latitude: 1, longitude: 1),
            Station.dummy(id: 2, latitude: 2, longitude: 2),
            Station.dummy(id: 3, latitude: 3, longitude: 3)
        ]
        
        let userLocation = CLLocation(latitude: 4, longitude: 4)
        
        giosApiRepositorySpy.fetchResult = .success(fetchResultStations)
        
        await userLocationRepositorySpy.setRequestLocationOnceResult(.success(userLocation))
        
        // When
        let result = try await sut.find()
        
        // Then
        let userLocationRepositorySpyEvents = await userLocationRepositorySpy.events
        
        XCTAssertEqual(result?.station.id, 3)
        XCTAssertEqual(userLocationRepositorySpyEvents, [.requestLocationOnce])
        XCTAssertEqual(result?.distance ?? 0, 156_760.13068588925, accuracy: 0.0000000002)
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetch(
                String(describing: [Station].self),
                Endpoint.Stations.get.urlRequest!,
                .cacheIfPossible
            )
        ])
    }
    
    func testFindWhenFetchingStationsFailed() async throws {
        // Given
        let userLocation = CLLocation(latitude: 4, longitude: 4)
        
        giosApiRepositorySpy.fetchResult = .failure(ErrorDummy())
        
        await userLocationRepositorySpy.setRequestLocationOnceResult(.success(userLocation))
        
        do {
            // When
            _ = try await sut.find()
            XCTFail("Find should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(giosApiRepositorySpy.events, [
                .fetch(
                    String(describing: [Station].self),
                    Endpoint.Stations.get.urlRequest!,
                    .cacheIfPossible
                )
            ])
        }
    }
    
    func testFindWhenGetUserLocationFailed() async throws {
        // Given
        let fetchResultStations = [
            Station.dummy(id: 1, latitude: 1, longitude: 1),
            Station.dummy(id: 2, latitude: 2, longitude: 2),
            Station.dummy(id: 3, latitude: 3, longitude: 3)
        ]
        
        giosApiRepositorySpy.fetchResult = .success(fetchResultStations)
        
        await userLocationRepositorySpy.setRequestLocationOnceResult(.failure(ErrorDummy()))
        
        do {
            // When
            _ = try await sut.find()
            XCTFail("Find should have thrown an error!")
        } catch {
            // Then
            let userLocationRepositorySpyEvents = await userLocationRepositorySpy.events
            
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(userLocationRepositorySpyEvents, [.requestLocationOnce])
            XCTAssertEqual(giosApiRepositorySpy.events, [
                .fetch(
                    String(describing: [Station].self),
                    Endpoint.Stations.get.urlRequest!,
                    .cacheIfPossible
                )
            ])
        }
    }
}
