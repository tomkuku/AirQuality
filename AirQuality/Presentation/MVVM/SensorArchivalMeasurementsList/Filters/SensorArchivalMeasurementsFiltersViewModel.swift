//
//  SensorArchivalMeasurementsFiltersViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/11/2025.
//

import Foundation
import Combine

final class SensorArchivalMeasurementsFiltersViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published var dateFrom: Date
    @Published var dateTo: Date
    @Published var dateSorting: SensorArchivalMeasurementsListOptions.Sorting.Date
    @Published var isValid: Bool = true
    
    var errors = SensorArchivalMeasurementsFiltersModel.ValidationError()
    
    // MARK: Private properties
    
    private let calendar = Calendar.current
    private var options: SensorArchivalMeasurementsListOptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    init(options: SensorArchivalMeasurementsListOptions) {
        self.options = options
        
        self.dateTo = options.filters.dateTo
        self.dateFrom = options.filters.dateFrom
        
        self.dateSorting = options.sorting.date
        
        Publishers.Merge(
            $dateFrom.map { _ in () },
            $dateTo.map { _ in () }
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.validate()
        }
        .store(in: &cancellables)
    }
    
    // MARK: Methods
    
    func clearFilters() {
        dateTo = Date()
        
        if let dateFrom = calendar.date(byAdding: .day, value: -14, to: dateTo) {
            self.dateFrom = dateFrom
        } else {
            Logger.error("Creating dateFrom failed!")
            self.dateFrom = Date()
        }
        
        isValid = true
        dateSorting = .descending
    }
    
    func validate() {
        errors = SensorArchivalMeasurementsFiltersModel.ValidationError()
        
        guard dateFrom <= dateTo else {
            errors.datesError = .dateFromCanNotBeGreaterThanDateTo
            isValid = false
            return
        }
        
        guard let days = calendar.dateComponents([.day], from: dateFrom, to: dateTo).day else {
            isValid = false
            return
        }
        
        if days > 365 {
            errors.datesError = .datesDifferenceCanNotBeGreaterThan365Days
            isValid = false
        }
        
        isValid = true
    }
}
