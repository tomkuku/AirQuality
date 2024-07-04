//
//  CacheDataSourceSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import Foundation

@testable import AirQuality

actor CacheDataSourceSpy: CacheDataSourceProtocol {
    enum Event {
        case set(URL?)
        case get(URL?)
    }
    
    var events: [Event] = []
    
    var setValue: Any?
    var getReturnValue: Any?
    
    func set<T>(url: URL?, value: T) async where T: Sendable {
        events.append(.set(url))
        setValue = value
    }
    
    func get<T>(url: URL?) async -> T? where T: Sendable {
        events.append(.get(url))
        return getReturnValue as? T
    }
}
