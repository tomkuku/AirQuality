//
//  SensorArchivalMeasurementsListViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 19/06/2024.
//

import XCTest
import Combine

@testable import AirQuality

final class SensorArchivalMeasurementsListViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: SensorArchivalMeasurementsListViewModel<FetchArchivalMeasurementsUseCaseSpy>!
    
    private var useCaseSpy: FetchArchivalMeasurementsUseCaseSpy!
    private var sensor: Sensor!
    
    private var items: [SensorArchivalMeasurementsListModel.Section]?
    private var state: PaginationFetchingState?
    private var error: Error?
    
    override func setUp() async throws {
        try await super.setUp()
        
        sensor = Sensor.dummy(id: 1, param: .pm10)
        useCaseSpy = FetchArchivalMeasurementsUseCaseSpy()
        
        await MainActor.run {
            sut = SensorArchivalMeasurementsListViewModel(sensor: sensor, useCase: useCaseSpy)
        }
    }
    
    // MARK: - fetchTheFirstPage
    
    @MainActor
    func testFetchTheFirstPage() async throws {
        // Given
        let measurements: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5),
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        
        useCaseSpy.fetchNextPageResult = .success(())
        useCaseSpy.streamValues = [
            (pageContent: measurements, areMorePages: false)
        ]
        
        sut.$state
            .filter { $0 == .noMorePages }
            .sink { _ in
                self.items = self.sut.items
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchTheFirstPage()
        
        // Wait for stream to emit value
        try await Task.sleep(nanoseconds: 100_000_000)
        await useCaseSpy.yieldStreamValue((pageContent: measurements, areMorePages: false))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(Set(useCaseSpy.events), Set([.getStream, .getParameters, .setParameters, .fetchNextPage]))
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.rows.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.state, .noMorePages)
    }
    
    @MainActor
    func testFetchTheFirstPageWhenFetchingFailed() async throws {
        // Given
        let expectedError = ErrorDummy()
        useCaseSpy.fetchNextPageResult = .failure(expectedError)
        
        sut.errorSubject
            .sink {
                self.error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        // Wait for getParameters and setParameters and getStream.
        try await Task.sleep(nanoseconds: 500_000_000)
        sut.fetchTheFirstPage()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(Set(useCaseSpy.events), ([.getStream, .getParameters, .setParameters, .fetchNextPage]))
        XCTAssertNotNil(error as? ErrorDummy)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - pageDidFetch
    
    @MainActor
    func testPageDidFetchWhenSingleMeasurement() async {
        // Given
        let measurement = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.rows.count, 1)
        XCTAssertEqual(items?.first?.rows.first?.formattedValue, "10.50")
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testPageDidFetchWhenMultipleMeasurementsInSameMonth() async {
        // Given
        let measurement1 = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        let measurement2 = SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement1, measurement2], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.rows.count, 2)
    }
    
    @MainActor
    func testPageDidFetchWhenMultipleMeasurementsInDifferentMonths() async {
        // Given
        let measurement1 = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        let measurement2 = SensorMeasurement.dummy(date: "2024-07-25 14:00", value: 20.3)
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement1, measurement2], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 2)
        XCTAssertEqual(items?.first?.rows.count, 1)
        XCTAssertEqual(items?.last?.rows.count, 1)
    }
    
    @MainActor
    func testPageDidFetchWhenMeasurementHasNoValue() async {
        // Given
        let measurement = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: nil)
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.rows.first?.formattedValue, "-")
    }
    
    @MainActor
    func testPageDidFetchWhenStateIsRefreshing() async {
        // Given
        let measurement1 = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        let measurement2 = SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        
        sut.state = .refreshing
        sut.items = [
            SensorArchivalMeasurementsListModel.Section(
                name: "Old Section",
                rows: [],
                year: 2024, // swiftlint:disable:this number_separator
                month: 5
            )
        ]
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement1, measurement2], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.name, "czerwiec - 24".capitalized)
        XCTAssertNil(items?.first(where: { $0.name == "Old Section" }))
    }
    
    @MainActor
    func testPageDidFetchWhenStateIsFetchingTheFirstPage() async {
        // Given
        let measurement = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        
        sut.state = .fetchingTheFirstPage
        sut.isLoading = true
        
        sut.$items
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.pageDidFetch([measurement], areMorePages: false)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - setOptions
    
    @MainActor
    func testSetOptions() async throws {
        // Given
        let dateFrom = Date()
        let dateTo = Calendar.current.date(byAdding: .day, value: 7, to: dateFrom)!
        let options = SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: .ascending)
        )
        
        useCaseSpy.refreshResult = .success(())
        useCaseSpy.streamValues = [
            (pageContent: [], areMorePages: false)
        ]
        
        sut.$state
            .first(where: { $0 == .noMorePages })
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        // Wait for stream to emit value
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.setOptions(options)
        
        await useCaseSpy.yieldStreamValue((pageContent: [], areMorePages: false))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue((useCaseSpy.events).contains([.setParameters]))
        XCTAssertTrue((useCaseSpy.events).contains([.refresh]))
        XCTAssertEqual(sut.options, options)
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.state, .noMorePages)
    }
    
    @MainActor
    func testSetOptionsWhenRefreshFailed() async throws {
        // Given
        let dateFrom = Date()
        let dateTo = Calendar.current.date(byAdding: .day, value: 7, to: dateFrom)!
        let options = SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: .ascending)
        )
        
        let expectedError = ErrorDummy()
        useCaseSpy.refreshResult = .failure(expectedError)
        
        sut.errorSubject
            .sink {
                self.error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.setOptions(options)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual((useCaseSpy.events).filter { $0 == .refresh }, [.refresh])
        XCTAssertNotNil(error as? ErrorDummy)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - setupStream
    
    @MainActor
    func testSetupStreamYieldsValues() async throws {
        // Given
        let measurement1 = SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        let measurement2 = SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        await useCaseSpy.yieldStreamValue((pageContent: [measurement1], areMorePages: true))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(sut.state, .readyToFetchNextPage)
        
        // When - Second value
        expectation = XCTestExpectation(description: "Second value")
        sut.$items
            .dropFirst()
            .sink {
                self.items = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await useCaseSpy.yieldStreamValue((pageContent: [measurement2], areMorePages: false))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.rows.count, 2)
        XCTAssertEqual(sut.state, .noMorePages)
    }
    
    // MARK: - setInitialOptions
    
    @MainActor
    func testSetInitialOptions() async {
        // Given
        let dateFrom = Date()
        let dateTo = Calendar.current.date(byAdding: .day, value: -14, to: dateFrom)!
        let expectedOptions = SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: .descending)
        )
        
        useCaseSpy.getParametersResult = expectedOptions
        
        // When - Wait for initialization
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual((useCaseSpy.events).filter { $0 == .getParameters }, [.getParameters])
    }
}
