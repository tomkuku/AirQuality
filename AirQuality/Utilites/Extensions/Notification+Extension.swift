//
//  Notification+Extension.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation

extension Notification.Name {
    static let localDatabaseDidChange = Notification.Name("localDatabaseDidChange")
    static let localDatabaseDidSave = Notification.Name("localDatabaseDidSave")
    static let locationDataSourceDidChangeAuthorization = Notification.Name("locationDataSourceDidChangeAuthorization")
    static let locationAuthorizationDidDenied = Notification.Name("locationAuthorizationDidDenied")
}
