//
//  XCUIElement.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 09/11/2025.
//

import Foundation
import XCTest

extension XCUIElement {
    func waitForExistence() -> Bool {
        self.waitForExistence(timeout: 15)
    }
}
