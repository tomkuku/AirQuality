//
//  FetchArchivalMeasurementsUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 19/06/2024.
//

import XCTest

@testable import AirQuality

// swiftlint:disable indentation_width
final class FetchArchivalMeasurementsUseCaseTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: FetchArchivalMeasurementsUseCase!
    
    private var giosApiRepositorySpy: GIOSApiV1RepositorySpy!
    private var sensorMeasurementDataFormatterSpy: SensorMeasurementDataFormatterSpy!
    
    private var sensor: Sensor!
    private var receivedValues: [(pageContent: [SensorMeasurement], areMorePages: Bool)]!
    private var receivedMeasurement: SensorMeasurement!
    
    override func setUp() {
        super.setUp()
        
        giosApiRepositorySpy = GIOSApiV1RepositorySpy()
        sensorMeasurementDataFormatterSpy = SensorMeasurementDataFormatterSpy()
        
        sensor = Sensor.dummy(id: 1, param: .pm10)
        
        dependenciesContainerDummy[\.sensorMeasurementsNetworkMapper] = SensorMeasurementNetworkMapper()
        dependenciesContainerDummy[\.sensorMeasurementDataFormatter] = sensorMeasurementDataFormatterSpy
        dependenciesContainerDummy[\.giosApiV1Repository] = giosApiRepositorySpy
        
        sut = FetchArchivalMeasurementsUseCase(sensor: sensor)
        
        receivedValues = []
    }
    
    // MARK: - fetchNextPage
    
    func testFetchNextPageWhenOnlyOnePage() async throws {
        // Given
        let expectedMeasurements: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5),
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        
        giosApiRepositorySpy.totalPages = 1
        giosApiRepositorySpy.fetchResultClosure = { _ in
            .success(expectedMeasurements as [Any])
        }
        
        // When
        Task {
            let stream = await sut.getStream()
            
            for try await value in stream {
                receivedValues.append(value)
            }
        }
        
        try await sut.fetchNextPage()
        
        // Wait for async stream to process
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(receivedValues.count, 1)
        XCTAssertEqual(receivedValues.first?.pageContent, expectedMeasurements)
        XCTAssertFalse(receivedValues.first?.areMorePages ?? true)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
    
    func testFetchNextPageWhenMoreThanOnePage() async throws {
        // Given
        let pageMeasurements1: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        ]
        let pageMeasurements2: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        let pageMeasurements3: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        
        var currentPage = 0
        
        giosApiRepositorySpy.fetchResultClosure = { [unowned self] _ in
            defer {
                currentPage += 1
            }
            
            if currentPage == 0 {
                self.giosApiRepositorySpy.totalPages = 2
                return .success(pageMeasurements1 as [Any])
            } else if currentPage == 1 {
                self.giosApiRepositorySpy.totalPages = 3
                return .success(pageMeasurements2 as [Any])
            } else {
                self.giosApiRepositorySpy.totalPages = 3
                return .success(pageMeasurements3 as [Any])
            }
        }
        
        // When
        Task {
            let stream = await sut.getStream()
            
            for try await value in stream {
                receivedValues.append(value)
            }
        }
        
        try await sut.fetchNextPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - First page should indicate more pages
        XCTAssertEqual(receivedValues.count, 1)
        XCTAssertEqual(receivedValues.first?.pageContent, pageMeasurements1)
        XCTAssertTrue(receivedValues.first?.areMorePages ?? false)
        
        // When - Fetch second page
        try await sut.fetchNextPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Second page should indicate more pages
        XCTAssertEqual(receivedValues.count, 2)
        XCTAssertEqual(receivedValues.last?.pageContent, pageMeasurements2)
        XCTAssertTrue(receivedValues.last?.areMorePages ?? false)
        
        // When - Fetch second page
        try await sut.fetchNextPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Third page should indicate no more pages
        XCTAssertEqual(receivedValues.count, 3)
        XCTAssertEqual(receivedValues.last?.pageContent, pageMeasurements3)
        XCTAssertFalse(receivedValues.last?.areMorePages ?? true)
    }
    
    func testFetchNextPage() async throws {
        // Given
        giosApiRepositorySpy.totalPages = 3
        var capturedPages: [Int] = []
        
        // Capture the page parameter from the URL request
        giosApiRepositorySpy.fetchResultClosure = {
            if let urlRequest = try? $0.asURLRequest(),
               let url = urlRequest.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let pageItem = queryItems.first(where: { $0.name == "page" }),
               let page = Int(pageItem.value ?? "") {
                capturedPages.append(page)
            }
            self.giosApiRepositorySpy.totalPages = 3
            return .success([SensorMeasurement]() as [Any])
        }
        
        // When
        try await sut.fetchNextPage() // Should fetch page 0, then increment to 1
        try await sut.fetchNextPage() // Should fetch page 1, then increment to 2
        try await sut.fetchNextPage() // Should fetch page 2, then increment to 3
        
        // Then
        XCTAssertEqual(capturedPages, [0, 1, 2])
        XCTAssertEqual(giosApiRepositorySpy.events.count, 3)
    }
    
    func testFetchNextPageWhenFetchingFailed() async throws {
        // Given
        let expectedError = NSError(domain: "stub", code: 42)
        giosApiRepositorySpy.fetchResultClosure = { _ in
            .failure(expectedError)
        }
        giosApiRepositorySpy.totalPages = 1
        
        // When & Then
        do {
            try await sut.fetchNextPage()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
    
    // MARK: - refresh
    
    func testRefresh() async throws {
        // Given
        giosApiRepositorySpy.totalPages = 3
        var capturedPages: [Int] = []
        
        giosApiRepositorySpy.fetchResultClosure = {
            if let urlRequest = try? $0.asURLRequest(),
               let url = urlRequest.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let pageItem = queryItems.first(where: { $0.name == "page" }),
               let page = Int(pageItem.value ?? "") {
                capturedPages.append(page)
            }
            self.giosApiRepositorySpy.totalPages = 3
            return .success([SensorMeasurement]() as [Any])
        }
        
        // When - Fetch some pages, then refresh
        try await sut.fetchNextPage() // page 0 -> 1
        try await sut.fetchNextPage() // page 1 -> 2
        try await sut.refresh() // Should reset to 0 and fetch page 0
        
        // Then
        XCTAssertEqual(capturedPages, [0, 1, 0])
        XCTAssertEqual(giosApiRepositorySpy.events.count, 3)
    }
    
    func testRefreshWhenFetchingFailed() async throws {
        // Given
        let expectedError = NSError(domain: "stub", code: 42)
        giosApiRepositorySpy.fetchResultClosure = { _ in
                .failure(expectedError)
        }
        giosApiRepositorySpy.totalPages = 1
        
        // When & Then
        do {
            try await sut.refresh()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
    
    // MARK: - setParameters
    
    func testSetParameters() async throws {
        // Given
        let dateFrom = Date()
        let dateTo = Calendar.current.date(byAdding: .day, value: 7, to: dateFrom)!
        let parameters = SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: .ascending)
        )
        
        var capturedSort: String?
        
        giosApiRepositorySpy.totalPages = 1
        giosApiRepositorySpy.fetchResultClosure = {
            if let urlRequest = try? $0.asURLRequest(),
               let url = urlRequest.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let sortItem = queryItems.first(where: { $0.name == "sort" }) {
                capturedSort = sortItem.value
            }
            return .success([SensorMeasurement]() as [Any])
        }
        
        // When
        await sut.setParameters(parameters)
        try await sut.fetchNextPage()
        
        // Then - Sort should be "Data" for ascending (from the endpoint implementation)
        XCTAssertEqual(capturedSort, "Data")
    }
    
    // MARK: - getParameters
    
    func testGetParametersWhenParametersAreDefault() async {
        // Given & When
        let parameters = await sut.getParameters()
        
        // Then
        XCTAssertEqual(parameters.sorting.date, .descending)
        let calendar = Calendar.current
        let dateTo = Date()
        let dateFrom = calendar.date(byAdding: .day, value: -14, to: dateTo)!
        XCTAssertEqual(parameters.filters.dateTo.timeIntervalSince1970, dateTo.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(parameters.filters.dateFrom.timeIntervalSince1970, dateFrom.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testGetParametersWhenParametersDidUpdated() async {
        // Given
        let dateFrom = Date()
        let dateTo = Calendar.current.date(byAdding: .day, value: 7, to: dateFrom)!
        let parameters = SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: .ascending)
        )
        
        // When
        await sut.setParameters(parameters)
        let retrievedParameters = await sut.getParameters()
        
        // Then
        XCTAssertEqual(retrievedParameters, parameters)
    }
}
// swiftlint:enable indentation_width
