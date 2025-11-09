//
//  ObservedStationsTests.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 19/05/2025.
//

import XCTest
import Foundation
import CoreLocation
import SnapshotTesting
import SwiftData

@testable import AirQuality

final class ObservedStationsTests: BaseUITestCase, @unchecked Sendable {
    
    @MainActor
    private var app: XCUIApplication!
    
    private var station1: Station!
    private var station2: Station!
    private var station3: Station!
    
    private var sqliteURL: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        station1 = Station(
            id: 437,
            latitude: 49.971047,
            longitude: 19.926189,
            cityName: "Skawina",
            province: "MAŁOPOLSKIE",
            street: "os. Ogrody"
        )
        
        station2 = Station(
            id: 400,
            latitude: 50.057678,
            longitude: 19.926189,
            cityName: "Kraków",
            province: "MAŁOPOLSKIE",
            street: "al. Krasińskiego"
        )
        
        station3 = Station(
            id: 459,
            latitude: 49.293564,
            longitude: 19.960083,
            cityName: "Zakopane",
            province: "MAŁOPOLSKIE",
            street: "ul. Sienkiewicza"
        )
        
        sqliteURL = try createBaseDatabase(with: [station1, station2, station3])
        
        await MainActor.run {
            app = XCUIApplication()
            app.setLaunchArguments([.uiTests, .specificDatabaseSqlitePath])
            app.setLaunchEnvironment([.uiTestsSqlitePath: sqliteURL.absoluteString])
            app.launch()
        }
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        
        try await MainActor.run {
            try FileManager.default.removeItem(at: sqliteURL)
        }
    }
    
    @MainActor
    func testLaunch() throws {
        let observedStationsList = app.collectionViews[\.observedStationsListView.stationsList]
        
        XCTAssertTrue(observedStationsList.waitForExistence())
        
        testSnapshot(imageName: "observedStations")
        
        XCTAssertEqual(observedStationsList.cells.count, 3)
        
        let cell = observedStationsList.cells.buttons[station2.street!]
        
        XCTAssertTrue(cell.exists)
        
        cell.tap()
        
        let sensorsScrollView = app.scrollViews[\.selectedStationView.sensorsList]
        
        XCTAssertTrue(sensorsScrollView.waitForExistence())
        
        sleep(2) /// Wait for animation completes.
        
        testSnapshot(imageName: "selectedStation")
        
        let refreshControl = app.otherElements[\.refreshableScrollView.refreshControl]
        
        let start = sensorsScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = sensorsScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
            
        start.press(forDuration: 0.8, thenDragTo: finish)
        
        XCTAssertTrue(refreshControl.waitForExistence(timeout: 2), "`refreshControl` does not exist")
    }
    
    // MARK: Private methods
    
    private func createBaseDatabase(with stations: [Station]) throws -> URL {
        let schema = Schema([StationLocalDatabaseModel.self])
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        
        let sqliteURL = temporaryDirectory.appendingPathComponent("AirQuality.sqlite")
        
        let configuration = ModelConfiguration(url: sqliteURL, allowsSave: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        
        let mapper = StationsLocalDatabaseMapper()
        
        try stations.forEach {
            let localDatabaseStation = try mapper.map($0)
            context.insert(localDatabaseStation)
        }
        
        try context.save()
        
        return sqliteURL
    }
    
    private func createArchivalMeasurementsList() async throws {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startDate = dateFormatter.date(from: "2025-11.05 13:34:54")!
        
        var measurements: [MeasurementNetworkModel] = []
        
        for i in 0..<80 {
            let date = calendar.date(byAdding: .hour, value: -i, to: startDate)!
            let dateString = dateFormatter.string(from: date)
            
            let measurementValue = Double.random(in: 0...300)
            
            let measurement = MeasurementNetworkModel(date: dateString, value: measurementValue)
            
            measurements.append(measurement)
        }
        
        let dateFrom = dateFormatter.date(from: "2025-10-26 00:00:00")!
        let dateTo = dateFormatter.date(from: "2025-11-09 23:59:00")!
        
        try await WireMockClient().addResponse(
            responseContent: measurements,
            totalPages: 12,
            for: Endpoint.ArchivalMeasurements.get(
                sensorId: 2752,
                page: 0,
                size: 80,
                options: .init(filters: .init(dateFrom: dateFrom, dateTo: dateTo), sorting: .init(date: .descending))
            )
        )
    }
}

extension MeasurementNetworkModel: Encodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(value, forKey: .value)
    }
}
