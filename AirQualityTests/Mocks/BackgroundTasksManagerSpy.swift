//
//  BackgroundTasksManagerSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class BackgroundTasksManagerSpy: BackgroundTasksManagerProtocol, @unchecked Sendable {
    
    enum Event {
        case beginFiniteLengthTask(String)
        case endFiniteLengthTask(String)
    }
    
    var expectation: XCTestExpectation?
    var events: [Event] = []
    
    func beginFiniteLengthTask(_ name: String, completion: (() -> ())?) {
        events.append(.beginFiniteLengthTask(name))
        expectation?.fulfill()
    }
    
    func endFiniteLengthTask(_ name: String) {
        events.append(.endFiniteLengthTask(name))
        expectation?.fulfill()
    }
}
