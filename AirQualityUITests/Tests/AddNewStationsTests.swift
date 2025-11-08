//
//  AddNewStationsTests.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 02/10/2024.
//

import XCTest
import Foundation
import CoreLocation

final class AddNewStationsTests: BaseUITestCase, @unchecked Sendable {
    
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
        testSnapshot(imageName: "noObservedStations")
        
        let noObservedStationsText = app.staticTexts[\.observedStationsListView.noObservedStations]
        
        XCTAssertTrue(noObservedStationsText.exists, "`noObservedStationsText` does not exist")
        
        let addObservedStationsButton = app.buttons[\.observedStationsListView.addObservedStationsButton]
        
        XCTAssertTrue(addObservedStationsButton.exists, "`addObservedStationsButton` does not exist")
        
        addObservedStationsButton.tap()
        
        // Add stations on list
        
        addStationOnList()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        addStationOnListWithSearching()
        
        // Add stations on map
        
        let tabBarMapButton = app.buttons[\.addObservedStationContainerView.tabViewMap]
        
        XCTAssertTrue(tabBarMapButton.exists, "`tabBarMapButton` does not exist")
        
        tabBarMapButton.tap()
        
        addStationOnMap()
        
        // Back to observed stations list
        
        let doneButton = app.otherElements[\.doneToolbarButton]
        
        XCTAssertTrue(doneButton.isHittable, "`doneButton` is not hittable")
        
        doneButton.tap()
        
        let observedStationsList = app.collectionViews[\.observedStationsListView.stationsList]
        
        XCTAssertTrue(observedStationsList.waitForExistence(timeout: 4), "`observedStationsList` does not exist")
        
        testSnapshot(imageName: "observedStationsAfterAddingStations")
    }
    
    @MainActor
    private func addStationOnList() {
        let provincesScrollView = app.scrollViews[\.provincesListView.provindesList]
        
        XCTAssertTrue(provincesScrollView.waitForExistence(timeout: 4), "`provincesScrollView` does not exist")
        
        testSnapshot(imageName: "provincesList")
        
        let secondProvinceButton = provincesScrollView.buttons.matching(keyPath: \.provincesListView.provindesListRow)
        
        /// Whole row is tappable!
        secondProvinceButton["Małopolskie"].tap()
        
        let stationsCollectionView = app.collectionViews[\.allStationsListView.stationsList]
        
        XCTAssertTrue(stationsCollectionView.waitForExistence(timeout: 4), "`stationsCollectionView` does not exist")
        
        testSnapshot(imageName: "provinceStationsList")
        
        tapCell(in: stationsCollectionView, index: 4)
        
        testSnapshot(imageName: "provinceStationsWithSelection")
    }
    
    @MainActor
    private func addStationOnListWithSearching() {
        let provincesScrollView = app.scrollViews[\.provincesListView.provindesList]
        
        XCTAssertTrue(provincesScrollView.waitForExistence(timeout: 4))
        
        testSnapshot(imageName: "provincesList")
                
        let searchBar = app.searchFields[Localizable.AddObservedStationListView.seach]
        
        XCTAssertTrue(searchBar.waitForExistence(timeout: 4), "`searchBar` does not exist")
        XCTAssertTrue(searchBar.isHittable, "`searchBar` is not hittable")
        
        searchBar.tap()
        searchBar.typeText("Kraków")
        
        testSnapshot(imageName: "provincesListAfterSearching")
        
        /// Whole row is tappable!
        let searchedProvinceButton = provincesScrollView.buttons.matching(keyPath: \.provincesListView.provindesListRow)
        searchedProvinceButton.element(boundBy: 0).tap()
        
        let stationsCollectionView = app.collectionViews[\.allStationsListView.stationsList]
        
        XCTAssertTrue(stationsCollectionView.waitForExistence(timeout: 4), "`stationsCollectionView` does not exist")
        
        testSnapshot(imageName: "provinceStationsListAfterSearching")
        
        tapCell(in: stationsCollectionView, index: 0)
        
        testSnapshot(imageName: "provinceStationsAfterSearchingWithSelection")
    }
    
    @MainActor
    private func addStationOnMap() {
        let mapBottomMenuGrabber = app.buttons[\.bottomSheet.grabber]
        
        XCTAssertTrue(mapBottomMenuGrabber.waitForExistence(timeout: 4), "`mapBottomMenuGrabber` does not exist")
        
        mapBottomMenuGrabber.tap()
        
        let findTheNearestStationButton = app.buttons[\.addObservedStationMapView.findTheNearestStationButton]
        
        XCTAssertTrue(findTheNearestStationButton.waitForExistence(timeout: 4), "`findTheNearestStationButton` does not exist")
        
        let deviceLocation = CLLocation(latitude: 51.202106161872145, longitude: 16.14441180827517)
        
        XCUIDevice.shared.location = XCUILocation(location: deviceLocation)
        
        findTheNearestStationButton.tap()
        
        do {
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let systemPermissionAlert = springboard.alerts.firstMatch
            
            XCTAssertTrue(systemPermissionAlert.waitForExistence(timeout: 4), "systemPermissionAlert does not exist")
            
            let allowOnceButton = systemPermissionAlert.buttons.allElementsBoundByIndex.first
            
            XCTAssertTrue(allowOnceButton?.waitForExistence(timeout: 4) == true, "allowOnceButton does not exist")
            XCTAssertTrue(allowOnceButton?.isHittable == true, "allowOnceButton is not hittable")
            
            allowOnceButton?.tap()
        }
        
        let annotation = app.images[\.stationMapAnnotationView.annotation]
        
        XCTAssertTrue(annotation.waitForExistence(timeout: 4), "`annotation` does not exist")
        
        annotation.tap()
        
        let addObservedStationButton = app.buttons[\.stationMapAnnotationView.addObservedStationButton]
        let paramsView = app.staticTexts[\.paramsView.params]
        
        XCTAssertTrue(paramsView.waitForExistence(timeout: 4), "`paramsView` does not exist")
        
        addObservedStationButton.tap()
        
        tapAtSpecificPoint(CGPoint(x: 100, y: 100), onApp: app)
    }
}
