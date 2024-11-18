//
//  AppError.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 18/11/2024.
//

import Foundation

/// Contains errors which can occour and be presented on every view on the app.
enum AppError: Error, Sendable, Equatable {
    case noInternetConnection
    case locationServices(UserLocationServicesError)
}
