//
//  MeasurementsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

struct MeasurementsNetworkMapper: NetworkMapperProtocol {
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    func map(_ input: [MeasurementNetworkModel]) throws -> [AirQuality.Measurement] {
        try input.compactMap {
            guard let date = dateFormatter.date(from: $0.date) else {
                throw NSError(domain: "MeasurementsNetworkMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Formatting date: \($0.date) failed!"
                ])
            }
            
            guard let value = $0.value else { return nil }
            
            return Measurement(
                date: date,
                value: value
            )
        }
    }
}
