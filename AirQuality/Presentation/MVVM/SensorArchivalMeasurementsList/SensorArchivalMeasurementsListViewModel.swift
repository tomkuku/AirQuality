//
//  SensorArchivalMeasurementsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

final class SensorArchivalMeasurementsListViewModel<UseCase>: BaseViewModel, PaginationViewModelProtocol
where UseCase: FetchArchivalMeasurementsUseCaseProtocol {
    
    typealias Item = Model.Section
    typealias Model = SensorArchivalMeasurementsListModel

    @Published var items: [Model.Section] = []
    @Published var state: PaginationFetchingState = .fetchingTheFirstPage
    
    let sensor: Sensor
    let useCase: UseCase
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd 'o' HH:mm"
        return dateFormatter
    }()
    
    private let monthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL - yy"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        return dateFormatter
    }()
    
    private let calendar = Calendar.current
    
    init(sensor: Sensor, useCase: UseCase) {
        self.sensor = sensor
        self.useCase = useCase
        
        super.init()
        
        setupStream()
    }
    
    func fetchingTheFirstPage() {
        Task { [weak self] in
            do {
                self?.isLoading = true
                self?.state = .fetchingTheFirstPage
                try await self?.useCase.fetchNextPage()
            } catch {
                Logger.error("Fetching the first page of archival measurements failed with error: \(error)")
                self?.errorSubject.send(error)
                self?.isLoading = false
            }
        }
    }
    
    func pageDidFetch(page: [SensorMeasurement]) {
        var items = self.items
        
        if state == .refreshing {
            items.removeAll()
        }
        
        page.forEach {
            let formattedValue: String
            let formattedDate = dateFormatter.string(from: $0.date)
            let measurementDateComponents = calendar.dateComponents([.year, .month], from: $0.date)
            let measurementDateYear = measurementDateComponents.year ?? 0
            let measurementDateMonth = measurementDateComponents.month ?? 0
            
            if let value = $0.measurement?.value {
                formattedValue = String(format: "%.2f", value)
            } else {
                formattedValue = "-"
            }
            
            let row = Model.Row(formattedValue: formattedValue, formattedDate: formattedDate, date: $0.date)
            
            if let lastElement = items.last?.rows.last {
                let lastElementDateComponents = calendar.dateComponents([.year, .month], from: lastElement.date)
                let lastElementYear = lastElementDateComponents.year ?? 0
                let lastElementMonth = lastElementDateComponents.month ?? 0
                
                if measurementDateYear == lastElementYear && measurementDateMonth == lastElementMonth {
                    items[items.count - 1].rows.append(row)
                } else {
                    let sectionName = monthFormatter.string(from: $0.date).capitalized
                    let section = Model.Section(
                        name: sectionName,
                        rows: [row],
                        year: measurementDateYear,
                        month: measurementDateMonth
                    )
                    items.append(section)
                }
            } else {
                let sectionName = monthFormatter.string(from: $0.date).capitalized
                let section = Model.Section(
                    name: sectionName,
                    rows: [row],
                    year: measurementDateYear,
                    month: measurementDateMonth
                )
                items.append(section)
            }
        }
        
        self.state = .none
        self.items = items
        self.isLoading = false
    }
}
