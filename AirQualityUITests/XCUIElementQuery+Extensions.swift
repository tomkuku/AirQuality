//
//  XCUIElementQuery+Extensions.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 19/05/2025.
//

import XCTest

@testable import AirQuality

extension XCUIElementQuery {
    subscript(_ keyPath: AccessibilityIdentifierType) -> XCUIElement {
        let key = String(describing: keyPath)
        return self[key]
    }
    
    func matching(keyPath: AccessibilityIdentifierType) -> XCUIElementQuery {
        let key = String(describing: keyPath)
        return self.matching(identifier: key)
    }
}
