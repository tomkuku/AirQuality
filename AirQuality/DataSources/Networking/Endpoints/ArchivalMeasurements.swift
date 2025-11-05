//
//  ArchivalMeasurements.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.ArchivalMeasurements: HTTPRequest {
    var path: String {
        switch self {
        case .get(let id, _, _, _):
            "/pjp-api/v1/rest/archivalData/getDataBySensor/" + "\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
            .get
        }
    }
    
    func createParams() throws -> [String: String]? {
        switch self {
        case .get(_, let page, let size, let options):
            let formattedDates = try formatDateToAndDateFrom(dateTo: options.filters.dateTo, dateFrom: options.filters.dateFrom)
            
            return [
                "page": "\(page)",
                "size": "\(size)",
                "dateFrom": formattedDates.0,
                "dateTo": formattedDates.1,
                "sort": options.sorting.date.queryItemText
            ]
        }
    }
    
    private func formatDateToAndDateFrom(dateTo: Date, dateFrom: Date) throws -> (String, String) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateFromStartOfDay = calendar.startOfDay(for: dateFrom)
        
        var dateToComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateTo)
        dateToComponents.hour = 23
        dateToComponents.minute = 59
        
        guard let dateToEndOfDay = calendar.date(from: dateToComponents) else {
            throw NSError(domain: String(describing: Self.self), code: -1, userInfo: [NSLocalizedDescriptionKey: "Formatting date to failed!"])
        }
        
        let formattedDateFrom = formatter.string(from: dateFromStartOfDay)
        let formattedDateTo = formatter.string(from: dateToEndOfDay)
        
        return (formattedDateFrom, formattedDateTo)
    }
}

private extension SensorArchivalMeasurementsListOptions.Sorting.Date {
    var queryItemText: String {
        switch self {
        case .descending:
            "-Data"
        case .ascending:
            "Data"
        }
    }
}
