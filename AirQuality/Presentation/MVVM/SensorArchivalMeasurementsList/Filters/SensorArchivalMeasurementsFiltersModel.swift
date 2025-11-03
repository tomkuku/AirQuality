//
//  SensorArchivalMeasurementsFiltersModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/11/2025.
//

import Foundation

struct SensorArchivalMeasurementsListOptions: Equatable {
    struct Filters: Equatable {
        let dateFrom: Date
        let dateTo: Date
    }
    
    struct Sorting: Equatable {
        enum Date: Int, Equatable {
            case descending
            case ascending
        }
        
        let date: Self.Date
        
        init(date: Self.Date) {
            self.date = date
        }
    }
    
    let filters: Filters
    let sorting: Sorting
}

struct SensorArchivalMeasurementsFiltersModel: Equatable {
    struct ValidationError: Error, Equatable {
        enum DateError: Error, Equatable {
            case datesDifferenceCanNotBeGreaterThan365Days
            case dateFromCanNotBeGreaterThanDateTo
        }
        
        var datesError: DateError?
    }
    
    var validationError: ValidationError
}

extension SensorArchivalMeasurementsFiltersModel.ValidationError.DateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .datesDifferenceCanNotBeGreaterThan365Days:
            "Ilość dni nie może być większa niż 365."
        case .dateFromCanNotBeGreaterThanDateTo:
            "Data rozpoczęcia nie może być większa niż data zakończenia"
        }
    }
}

extension SensorArchivalMeasurementsListOptions.Sorting.Date: CaseIterable, Identifiable, Hashable {
    var id: Int {
        rawValue
    }
    
    var localizedShortTitle: String {
        switch self {
        case .ascending:
            "Od najstarszych"
        case .descending:
            "Od najnowszych"
        }
    }
    
    var localizedLongTitle: String {
        switch self {
        case .ascending:
            "Od najstarszych (rosnąco)"
        case .descending:
            "Od najnowszych (malejąco)"
        }
    }
}
