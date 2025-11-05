//
//  GIOSApiV1RepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 19/06/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class GIOSApiV1RepositoryTests: BaseTestCase {
    
    private var sut: GIOSApiV1Repository!
    private var httpDataSourceMock: HTTPDataSourceMock!
    
    override func setUp() {
        super.setUp()
        
        httpDataSourceMock = HTTPDataSourceMock()
        sut = GIOSApiV1Repository(httpDataSource: httpDataSourceMock)
    }
    
    // MARK: - Fetch
    
    func testFetchWhenSuccess() async throws {
        // Given
        let expectedDomainModel = [DomainModelFake(name: "Test Name")]
        let expectedTotalPages = 42
        let dtoModel = [DTOModelFake(name: "Test Name")]
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperFake()
        mapper.mapResult = .success(expectedDomainModel)
        
        // When
        let result = try await sut.fetch(
            mapper: mapper,
            endpoint: EndpointFake(),
            mappingInputParameters: ()
        )
        
        // Then
        XCTAssertEqual(result.output.first?.name, expectedDomainModel.first?.name)
        XCTAssertEqual(result.totalPages, expectedTotalPages)
        XCTAssertEqual(httpDataSourceMock.events.count, 1)
        XCTAssertEqual(mapper.mapCallCount, 1)
        XCTAssertEqual(mapper.lastInput?.first?.name, dtoModel.first?.name)
    }
    
    func testFetchWhenHTTPDataSourceFailure() async {
        // Given
        let expectedError = ErrorDummy()
        httpDataSourceMock.requestDataResult = .failure(expectedError)
        
        let mapper = NetworkMapperFake()
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: mapper,
                endpoint: EndpointFake(),
                mappingInputParameters: ()
            )
            XCTFail("Fetch should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(httpDataSourceMock.events.count, 1)
            XCTAssertEqual(mapper.mapCallCount, 0)
        }
    }
    
    func testFetchWhenJSONDecodingFailure() async {
        // Given
        let invalidJSON = "invalid json".data(using: .utf8)!
        httpDataSourceMock.requestDataResult = .success(invalidJSON)
        
        let mapper = NetworkMapperFake()
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: mapper,
                endpoint: EndpointFake(),
                mappingInputParameters: ()
            )
            XCTFail("Fetch should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is DecodingError)
            XCTAssertEqual(httpDataSourceMock.events.count, 1)
            XCTAssertEqual(mapper.mapCallCount, 0)
        }
    }
    
    func testFetchWhenMappingFailure() async {
        // Given
        let expectedTotalPages = 10
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperFake()
        let expectedError = ErrorDummy()
        mapper.mapResult = .failure(expectedError)
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: mapper,
                endpoint: EndpointFake(),
                mappingInputParameters: ()
            )
            XCTFail("Fetch should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(httpDataSourceMock.events.count, 1)
            XCTAssertEqual(mapper.mapCallCount, 1)
        }
    }
    
    func testFetchWhenMappingFailureWithInputParameters() async {
        // Given
        let expectedTotalPages = 10
        let inputParameters = InputParametersFake(value: "input")
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperWithInputFake()
        let expectedError = ErrorDummy()
        mapper.mapResult = .failure(expectedError)
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: mapper,
                endpoint: EndpointFake(),
                mappingInputParameters: inputParameters
            )
            XCTFail("Fetch should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(httpDataSourceMock.events.count, 1)
            XCTAssertEqual(mapper.mapCallCount, 1)
        }
    }
    
    func testFetchWithInputParameters() async throws {
        // Given
        let expectedDomainModel = [DomainModelFake(name: "Mapped Name")]
        let expectedTotalPages = 5
        let inputParameters = InputParametersFake(value: "input")
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperWithInputFake()
        mapper.mapResult = .success(expectedDomainModel)
        
        // When
        let result = try await sut.fetch(
            mapper: mapper,
            endpoint: EndpointFake(),
            mappingInputParameters: inputParameters
        )
        
        // Then
        XCTAssertEqual(result.output.first?.name, expectedDomainModel.first?.name)
        XCTAssertEqual(result.totalPages, expectedTotalPages)
        XCTAssertEqual(httpDataSourceMock.events.count, 1)
        XCTAssertEqual(mapper.mapCallCount, 1)
        XCTAssertEqual(mapper.lastInputParameters?.value, inputParameters.value)
    }
    
    func testFetchWithNoInputParametersReturnsDomainModel() async throws {
        // Given
        let expectedDomainModel = [DomainModelFake(name: "Test Name")]
        let expectedTotalPages = 15
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperFake()
        mapper.mapResult = .success(expectedDomainModel)
        
        // When
        let result: [DomainModelFake] = try await sut.fetch(
            mapper: mapper,
            endpoint: EndpointFake()
        )
        
        // Then
        XCTAssertEqual(result.first?.name, expectedDomainModel.first?.name)
        XCTAssertEqual(httpDataSourceMock.events.count, 1)
        XCTAssertEqual(mapper.mapCallCount, 1)
    }
    
    func testFetchWithInputParametersReturnsDomainModel() async throws {
        // Given
        let expectedDomainModel = [DomainModelFake(name: "Mapped Name")]
        let inputParameters = InputParametersFake(value: "input")
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": 20
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperWithInputFake()
        mapper.mapResult = .success(expectedDomainModel)
        
        // When
        let result: [DomainModelFake] = try await sut.fetch(
            mapper: mapper,
            endpoint: EndpointFake(),
            mappingInputParameters: inputParameters
        )
            
        // Then
        XCTAssertEqual(result.first?.name, expectedDomainModel.first?.name)
        XCTAssertEqual(httpDataSourceMock.events.count, 1)
        XCTAssertEqual(mapper.mapCallCount, 1)
        XCTAssertEqual(mapper.lastInputParameters?.value, inputParameters.value)
    }
    
    func testFetchWithNoInputParametersReturnsDomainModelAndTotalPages() async throws {
        // Given
        let expectedDomainModel = [DomainModelFake(name: "Test Name")]
        let expectedTotalPages = 25
        
        let jsonData = """
        {
            "Lista stacji pomiarowych": [{
                "name": "Test Name"
            }],
            "totalPages": \(expectedTotalPages)
        }
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(jsonData)
        
        let mapper = NetworkMapperFake()
        mapper.mapResult = .success(expectedDomainModel)
        
        // When
        let result: (output: [DomainModelFake], totalPages: Int) = try await sut.fetch(
            mapper: mapper,
            endpoint: EndpointFake()
        )
        
        // Then
        XCTAssertEqual(result.output.first?.name, expectedDomainModel.first?.name)
        XCTAssertEqual(result.totalPages, expectedTotalPages)
        XCTAssertEqual(httpDataSourceMock.events.count, 1)
        XCTAssertEqual(mapper.mapCallCount, 1)
    }
}
