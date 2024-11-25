//
//  PropertyListDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 18/11/2024.
//

import Foundation

enum AppConstant {
    static subscript(_ propertyName: PropertyName) -> String {
        guard let appConstants = Bundle.main.object(forInfoDictionaryKey: "APP_CONSTANTS") as? [String: String] else {
            fatalError("No APP_CONSTANTS dictionary in Info.plist!")
        }
        
        guard let property = appConstants[propertyName.rawValue] else {
            fatalError("No property with name: \(propertyName.rawValue) in appConstants!")
        }
        
        return property
    }
}

extension AppConstant {
    enum PropertyName: String {
        case giosApiBaseUrl = "GIOS_API_BASE_URL"
    }
}
