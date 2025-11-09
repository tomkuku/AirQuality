//
//  Array+Extension.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension Decodable {
    func isArray() -> Bool {
        self is [Any]
    }
}
