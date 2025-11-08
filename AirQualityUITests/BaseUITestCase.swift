//
//  BaseUITestCase.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 08/11/2025.
//

import Foundation
import XCTest

@testable import AirQuality

@MainActor
class BaseUITestCase: XCTestCase, @unchecked Sendable { // swiftlint:disable:this final_test_case
    
    override func record(_ issue: XCTIssue) {
        super.record(issue)
        
        DispatchQueue.main.async {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            
            attachment.lifetime = .keepAlways
            attachment.name = "Failure Screenshot"
            
            self.add(attachment)
        }
    }
}
