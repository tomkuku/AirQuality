//
//  AirQualityUITestsLaunchTests.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 02/10/2024.
//

import XCTest
import Foundation
import CoreLocation
import SnapshotTesting

@testable import AirQuality

// swiftlint:disable balanced_xctest_lifecycle
final class AirQualityUITestsLaunchTests: XCTestCase, @unchecked Sendable {
    
    @MainActor
    private var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        
        await MainActor.run { [weak self] in
            self?.app = XCUIApplication()
            self?.app.launchArguments = ["-uitests"]
            self?.app.resetAuthorizationStatus(for: .location)
            self?.app.launch()
        }
    }
    
    @MainActor
    func testLaunch() {
        testSnapshot(imageName: "noObserbedStations")
        
        let noObservedStationsText = app.staticTexts[AccessibilityIdentifiers.ObservedStationsListView.noObservedStations.rawValue]
        
        XCTAssertTrue(noObservedStationsText.exists)
        
        let addObservedStationsButton = app.buttons[ AccessibilityIdentifiers.ObservedStationsListView.addObservedStationsButton.rawValue]
        
        XCTAssertTrue(addObservedStationsButton.exists)
        
        addObservedStationsButton.tap()
        
        let provincesCollectionView = app.collectionViews[AccessibilityIdentifiers.AllStationsListProvindesView.provindesList.rawValue]
        
        XCTAssertTrue(provincesCollectionView.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "provincesList")
        
        tapCell(in: provincesCollectionView, index: 1)
        
        let stationsCollectionView = app.collectionViews[AccessibilityIdentifiers.AllStationsListProvinceStationsView.stationsList.rawValue]
        
        XCTAssertTrue(stationsCollectionView.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "provinceStationsList")
        
        tapCell(in: stationsCollectionView, index: 0)
        
        testSnapshot(imageName: "provinceStationsWithSelection")
        
        let mapButton = app.buttons[AccessibilityIdentifiers.AddObservedStationContainerView.tabViewMap.rawValue]
        
        XCTAssertTrue(mapButton.exists)
        
        mapButton.tap()
        
        let mapBottomMenuGrabber = app.buttons[AccessibilityIdentifiers.BottomSheet.grabber.rawValue]
        
        XCTAssertTrue(mapBottomMenuGrabber.waitForExistence(timeout: 4))
        
        mapBottomMenuGrabber.tap()
        
        let findTheNearestStationButton = app.buttons[AccessibilityIdentifiers.AddObservedStationMapView.findTheNearestStationButton.rawValue]
        
        XCTAssertTrue(findTheNearestStationButton.waitForExistence(timeout: 4))
        
        let deviceLocation = CLLocation(latitude: 51.202106161872145, longitude: 16.14441180827517)
        
        XCUIDevice.shared.location = XCUILocation(location: deviceLocation)
        
        findTheNearestStationButton.tap()
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowOnceButton = springboard.alerts.element(boundBy: 0).buttons.element(boundBy: 0)
        
        XCTAssertTrue(allowOnceButton.waitForExistence(timeout: 4))
        
        allowOnceButton.tap()
        
        _ = consume springboard
        
        let annotation = app.images[AccessibilityIdentifiers.StationMapAnnotationView.annotation.rawValue]
        
        XCTAssertTrue(annotation.waitForExistence(timeout: 4))
        
        annotation.tap()
        
        let addObservedStationButton = app.buttons[AccessibilityIdentifiers.StationMapAnnotationView.addObservedStationButton.rawValue]
        let paramsView = app.staticTexts[AccessibilityIdentifiers.ParamsView.params.rawValue]
        
        XCTAssertTrue(paramsView.waitForExistence(timeout: 4))
        
        addObservedStationButton.tap()
        
        tapAtSpecificPoint(CGPoint(x: 100, y: 100), onApp: app)
        
        let doneButton = app.otherElements[AccessibilityIdentifiers.doneToolbarButton.rawValue]
        
        XCTAssertTrue(doneButton.isHittable)
        
        doneButton.tap()
        
        let observedStationsList = app.collectionViews[AccessibilityIdentifiers.ObservedStationsListView.stationsList.rawValue]
        
        XCTAssertTrue(observedStationsList.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "observedStations")
        
        tapCell(in: observedStationsList, index: 0)
        
        let sensorsList = app.scrollViews[AccessibilityIdentifiers.SelectedStationView.sensorsList.rawValue]
        
        XCTAssertTrue(sensorsList.waitForExistence(timeout: 4))
    }
    
    @MainActor
    private func tapAtSpecificPoint(_ point: CGPoint, onApp app: XCUIApplication) {
        let point = CGVector(dx: point.x, dy: point.y)
        let coordinate = app.coordinate(withNormalizedOffset: .zero)
        let targetCoordinate = coordinate.withOffset(point)
        
        targetCoordinate.tap()
    }
    
    @MainActor
    private func tapCell(in collectionView: XCUIElement, index cellIndex: Int) {
        let firstCell = collectionView.cells.element(boundBy: cellIndex)
        
        XCTAssertTrue(firstCell.exists)
        
        firstCell.tap()
    }
    
    @MainActor
    private func testSnapshot(imageName: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let snapshot = UIImage(data: screenshot.pngRepresentation)!
        
        assertSnapshot(
            of: snapshot,
            as: .image(precision: 0.98),
            record: false,
            testName: imageName
        )
    }
}
// swiftlint:enable balanced_xctest_lifecycle
