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

final class ObservedStationsTests: XCTestCase, @unchecked Sendable {
    
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
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try FileManager.default.removeItem(at: sqliteURL)
    }
    
    @MainActor
    func testLaunch() throws {
        let observedStationsList = app.collectionViews[\.observedStationsListView.stationsList]
        
        XCTAssertTrue(observedStationsList.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "observedStations")
        
        XCTAssertEqual(observedStationsList.cells.count, 3)
        
        let cell = observedStationsList.cells.buttons[station2.street!]
        
        XCTAssertTrue(cell.exists)
        
        cell.tap()
        
        let sensorsList = app.scrollViews[\.selectedStationView.sensorsList]
        
        XCTAssertTrue(sensorsList.waitForExistence(timeout: 4))
        
        sleep(2) /// Wait for animation completes.
        
        testSnapshot(imageName: "selectedStation")
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
}
