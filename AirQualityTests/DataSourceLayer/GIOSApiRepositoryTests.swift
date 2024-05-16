//
//  GIOSApiRepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class GIOSApiRepositoryTest: BaseTestCase {
    
//    private var httpDataSourceMock: HTTPDataSourceMock!
//    private var sut: GIOSApiRepository!
//    
//    override func setUp() {
//        super.setUp()
//        
//        httpDataSourceMock = HTTPDataSourceMock()
//        
//        sut = GIOSApiRepository(httpDataSource: httpDataSourceMock)
//        
//        MapperSpy.events.removeAll()
//    }
//    
//    func testFetchWhenSuccess() async throws {
//        // Given
//        let data = """
//        {
//            "test-content": [
//                {
//                    "name": "James"
//                },
//                {
//                    "name": "Mike"
//                }
//            ]
//        }
//        """.data(using: .utf8)!
//        
//        httpDataSourceMock.requestDataResult = .success(data)
//        
//        MapperSpy.mapResult = .success([.init(name: "Jack")])
//        
//        // When
//        let objects = try await sut.fetch(
//            mapperType: MapperSpy.self,
//            endpoint: EndpointFake(),
//            contentContainerName: "test-content"
//        )
//        
//        // Then
//        XCTAssertEqual(objects.first?.name, "Jack")
//        XCTAssertEqual(MapperSpy.events, [.map])
//        XCTAssertEqual(MapperSpy.inputs, [.init(name: "James"), .init(name: "Mike")])
//    }
//    
//    func testFetchWhenNetworkDataSourceFailure() async {
//        // Given
//        httpDataSourceMock.requestDataResult = .failure(ErrorDummy())
//        
//        // When
//        do {
//            _ = try await sut.fetch(
//                mapperType: MapperSpy.self,
//                endpoint: EndpointFake(),
//                contentContainerName: "test-content"
//            )
//            XCTFail("Fetch should have throw!")
//        } catch {
//            // Then
//            XCTAssertTrue(error is ErrorDummy)
//        }
//    }
//    
//    func testFetchWhenMappingFailure() async {
//        // Given
//        let data = """
//        {
//            "test-content": [
//                {
//                    "name": "James"
//                },
//                {
//                    "name": "Mike"
//                }
//            ]
//        }
//        """.data(using: .utf8)!
//        
//        httpDataSourceMock.requestDataResult = .success(data)
//        
//        MapperSpy.mapResult = .failure(ErrorDummy())
//        
//        // When
//        do {
//            _ = try await sut.fetch(
//                mapperType: MapperSpy.self,
//                endpoint: EndpointFake(),
//                contentContainerName: "test-content"
//            )
//            XCTFail("Fetch should have throw!")
//        } catch {
//            // Then
//            XCTAssertTrue(error is ErrorDummy)
//        }
//    }
//    
//    private struct DomainModelFake {
//        let name: String
//    }
//    
//    private struct NetworkModelFake: Decodable, Equatable {
//        let name: String
//    }
//    
//    private final class MapperSpy: MapperProtocol {
//        enum Event {
//            case map
//        }
//        
//        nonisolated(unsafe) static var events: [Event] = []
//        
//        nonisolated(unsafe) static var mapResult: Result<[DomainModelFake], Error> = .failure(ErrorDummy())
//        nonisolated(unsafe) static var inputs: [NetworkModelFake]?
//        
//        func map(_ input: [NetworkModelFake]) throws -> [DomainModelFake] {
//            Self.events.append(.map)
//            Self.inputs = input
//            
//            switch Self.mapResult {
//            case .success(let models):
//                return models
//            case .failure(let error):
//                throw error
//            }
//        }
//    }
}
