//
//  Notification+Extension.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation

extension Notification.Name {
    static let persistentModelDidChange = Notification.Name("persistentModelDidChange")
    static let persistentModelDidSave = Notification.Name("persistentModelDidSave")
}
