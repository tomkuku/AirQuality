//
//  EnvironmentConstants.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/08/2025.
//

import Foundation

protocol HasEnvironmentConstantsProtocol {
    var environmentConstants: any EnvironmentConstantsProtocol { get }
}

protocol EnvironmentConstantsProtocol {
    subscript<T>(_ keyPath: KeyPath<Self, T>) -> T { get }
    
    var baseUrl: String { get }
}

extension EnvironmentConstantsProtocol {
    subscript<T>(_ keyPath: KeyPath<Self, T>) -> T {
        self[keyPath: keyPath]
    }
}

#if PROD
final class EnvironmentConstants: EnvironmentConstantsProtocol {
    var baseUrl: String {
        "https://api.gios.gov.pl"
    }
}
#elseif TESTS
final class TestsEnvironmentConstant: EnvironmentConstantsProtocol {
    var baseUrl: String {
        "http://localhost:8080"
    }
}
#else
final class DevelopmentEnvironmentConstants: EnvironmentConstantsProtocol {
    var baseUrl: String {
        "https://api.gios.gov.pl"
    }
}
#endif
