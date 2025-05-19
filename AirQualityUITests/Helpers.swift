//
//  Helpers.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 19/05/2025.
//

import Foundation
import XCTest
import class UIKit.UIImage
import SnapshotTesting

@MainActor
func testSnapshot(imageName: String) {
    let screenshot = XCUIScreen.main.screenshot()
    let snapshot = UIImage(data: screenshot.pngRepresentation)!
    
    assertSnapshot(
        of: snapshot,
        as: .image(precision: 0.90),
        record: false,
        testName: imageName
    )
}

@MainActor
func tapCell(in collectionView: XCUIElement, index cellIndex: Int) {
    let firstCell = collectionView.cells.element(boundBy: cellIndex)
    
    XCTAssertTrue(firstCell.exists)
    
    firstCell.tap()
}
