//
//  ConfigurationConstants.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/08/2025.
//

import Foundation

enum GlobalConstant {}

final class EnvironmentConstant {
    private nonisolated(unsafe) static let shared = EnvironmentConstant()
    
    static subscript<T>(_ keyPath: KeyPath<EnvironmentConstant, T>) -> T {
        shared[keyPath: keyPath]
    }
    
    let baseUrl: String = {
        "https://api.gios.gov.pl"
    }()
}
