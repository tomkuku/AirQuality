//
//  AddNewStationsTests.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 02/10/2024.
//

import XCTest
import Foundation
import CoreLocation
import SnapshotTesting

// swiftlint:disable balanced_xctest_lifecycle
final class AddNewStationsTests: XCTestCase, @unchecked Sendable {
    
    @MainActor
    private var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        
        await MainActor.run {
            app = XCUIApplication()
            app.setLaunchArguments([.datatbaseStoreInMemoryOnly])
            app.resetAuthorizationStatus(for: .location)
            app.launch()
        }
    }
    
    @MainActor
    func testLaunch() {
        testSnapshot(imageName: "noObserbedStations")
        
        let noObservedStationsText = app.staticTexts[\.observedStationsListView.noObservedStations]
        
        XCTAssertTrue(noObservedStationsText.exists)
        
        let addObservedStationsButton = app.buttons[\.observedStationsListView.addObservedStationsButton]
        
        XCTAssertTrue(addObservedStationsButton.exists)
        
        addObservedStationsButton.tap()
        
        // Add stations on list
        
        let provincesScrollView = app.scrollViews[\.provincesListView.provindesList]
        
        XCTAssertTrue(provincesScrollView.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "provincesList")
                
        let searchBar = app.searchFields[Localizable.AddObservedStationListView.seach]
        
        XCTAssertTrue(searchBar.waitForExistence(timeout: 4))
        XCTAssertTrue(searchBar.isHittable)
        
        searchBar.tap()
        searchBar.typeText("Kraków")
        
        testSnapshot(imageName: "provincesListAfterSearching")
        
        /// Whole row is tappable!
        let images = provincesScrollView.images.matching(keyPath: \.provincesListView.provindesListRow)
        images.element(boundBy: 0).tap()
        
        let stationsCollectionView = app.collectionViews[\.allStationsListView.stationsList]
        
        XCTAssertTrue(stationsCollectionView.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "provinceStationsList")
        
        tapCell(in: stationsCollectionView, index: 0)
        
        testSnapshot(imageName: "provinceStationsWithSelection")
        
        // Add stations on map
        
        let mapButton = app.buttons[\.addObservedStationContainerView.tabViewMap]
        
        XCTAssertTrue(mapButton.exists)
        
        mapButton.tap()
        
        let mapBottomMenuGrabber = app.buttons[\.bottomSheet.grabber]
        
        XCTAssertTrue(mapBottomMenuGrabber.waitForExistence(timeout: 4))
        
        mapBottomMenuGrabber.tap()
        
        let findTheNearestStationButton = app.buttons[\.addObservedStationMapView.findTheNearestStationButton]
        
        XCTAssertTrue(findTheNearestStationButton.waitForExistence(timeout: 4))
        
        let deviceLocation = CLLocation(latitude: 51.202106161872145, longitude: 16.14441180827517)
        
        XCUIDevice.shared.location = XCUILocation(location: deviceLocation)
        
        findTheNearestStationButton.tap()
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowOnceButton = springboard.alerts.element(boundBy: 0).buttons.element(boundBy: 0)
        
        XCTAssertTrue(allowOnceButton.waitForExistence(timeout: 4))
        
        allowOnceButton.tap()
        
        _ = consume springboard
        
        let annotation = app.images[\.stationMapAnnotationView.annotation]
        
        XCTAssertTrue(annotation.waitForExistence(timeout: 4))
        
        annotation.tap()
        
        let addObservedStationButton = app.buttons[\.stationMapAnnotationView.addObservedStationButton]
        let paramsView = app.staticTexts[\.paramsView.params]
        
        XCTAssertTrue(paramsView.waitForExistence(timeout: 4))
        
        addObservedStationButton.tap()
        
        tapAtSpecificPoint(CGPoint(x: 100, y: 100), onApp: app)
        
        let doneButton = app.otherElements[\.doneToolbarButton]
        
        XCTAssertTrue(doneButton.isHittable)
        
        doneButton.tap()
        
        let observedStationsList = app.collectionViews[\.observedStationsListView.stationsList]
        
        XCTAssertTrue(observedStationsList.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "observedStationsAfterAddingStations")
        
        app.terminate()
    }
    
    @MainActor
    private func tapAtSpecificPoint(_ point: CGPoint, onApp app: XCUIApplication) {
        let point = CGVector(dx: point.x, dy: point.y)
        let coordinate = app.coordinate(withNormalizedOffset: .zero)
        let targetCoordinate = coordinate.withOffset(point)
        
        targetCoordinate.tap()
    }
}
// swiftlint:enable balanced_xctest_lifecycle
