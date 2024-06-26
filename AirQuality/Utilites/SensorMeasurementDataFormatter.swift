//
//  SensorMeasurementDataFormatter.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import Foundation

protocol HasSensorMeasurementDataFormatter {
    var sensorMeasurementDataFormatter: SensorMeasurementDataFormatterProtocol { get }
}

protocol SensorMeasurementDataFormatterProtocol: Sendable {
    func date(from string: String) -> Date?
    func format(date: Date) -> String
}

final class SensorMeasurementDataFormatter: SensorMeasurementDataFormatterProtocol {
    private let dateDateFormatter: DateFormatter
    private let stringDateFormatter: DateFormatter
    
    init() {
        self.dateDateFormatter = DateFormatter()
        self.dateDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.stringDateFormatter = DateFormatter()
        self.stringDateFormatter.dateStyle = .medium
        self.stringDateFormatter.timeStyle = .short
    }
    
    func date(from string: String) -> Date? {
        dateDateFormatter.date(from: string)
    }
    
    func format(date: Date) -> String {
        stringDateFormatter.string(from: date)
    }
}
