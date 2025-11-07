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

@testable import AirQuality

@MainActor
func testSnapshot(imageName: String) {
    let screenshot = XCUIScreen.main.screenshot()
    let snapshot = UIImage(data: screenshot.pngRepresentation)!
    
    assertSnapshot(
        of: snapshot,
        as: .image(precision: 0.95),
        named: "test",
        record: false,
        testName: imageName,
    )
}

@MainActor
func tapCell(in collectionView: XCUIElement, index cellIndex: Int) {
    let firstCell = collectionView.cells.element(boundBy: cellIndex)
    
    XCTAssertTrue(firstCell.exists)
    
    firstCell.tap()
}

extension StationNetworkModel: Encodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(province, forKey: .province)
        try container.encode(street, forKey: .street)
    }
}

struct GIOSApiV1ResponseMock<T, K>: Encodable where T: Encodable, K: CodingKey {
    struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            stringValue = "nil"
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    private let content: T
    private let containerName: GIOSApiV1.ContainerName
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: K.self)
        
        try container.encode(content, forKey: .init(stringValue: containerName.rawValue)!)
    }
}
