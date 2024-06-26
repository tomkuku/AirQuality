//
//  SensorMeasurementDataFormatterSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 25/06/2024.
//

import XCTest

@testable import AirQuality

final class SensorMeasurementDataFormatterSpy: SensorMeasurementDataFormatterProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case date(String)
        case format(String)
    }
    
    var events: [Event] = []
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    private let dateDateFormatter: DateFormatter = {
        let dateDateFormatter = DateFormatter()
        dateDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateDateFormatter
    }()
    
    private let stringDateFormatter: DateFormatter = {
        let stringDateFormatter = DateFormatter()
        stringDateFormatter.dateStyle = .medium
        stringDateFormatter.timeStyle = .short
        return stringDateFormatter
    }()
    
    func date(from string: String) -> Date? {
        events.append(.date(string))
        
        return dateDateFormatter.date(from: string)
    }
    
    func format(date: Date) -> String {
        events.append(.format(dateFormatter.string(from: date)))
        
        return stringDateFormatter.string(from: date)
    }
}
