//
//  XCUIElement.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 09/11/2025.
//

import Foundation
import XCTest

extension XCUIElement {
    private var waitForExistenceTimeout: TimeInterval {
        guard
            let timeoutString = ProcessInfo.processInfo.environment["WAIT_FOR_EXISTENCE_TIMEOUT"],
            let timeout = TimeInterval(timeoutString)
        else {
            return 4
        }
        
        return timeout
    }
    
    func waitForExistence() -> Bool {
        self.waitForExistence(timeout: waitForExistenceTimeout)
    }
}
