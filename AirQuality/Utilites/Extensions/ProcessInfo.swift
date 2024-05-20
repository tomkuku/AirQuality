//
//  Processinfo.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension ProcessInfo {
    static var isTest: Bool {
        processInfo.environment["IS_TEST"] != nil
    }
}
