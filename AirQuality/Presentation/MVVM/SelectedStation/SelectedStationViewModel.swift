//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

@MainActor
final class SelectedStationViewModel: BaseViewModel {
    
    typealias Model = SelectedStationModel
    
    // MARK: Properties
    
    @Published private(set) var sensors: [Model.SensorRow] = []
    
    var formattedStationAddress: String {
        if let stationStreet = station.street {
            return station.cityName + ", " + stationStreet
        }
        
        return station.cityName
    }
    
    private let measurementValueMeasurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private let measurementPercentageValueNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    let station: Station
    
    private var fetchedSensors: [Sensor] = []
    
    // MARK: Private properties
    
    @Injected(\.getSensorsUseCase) private var getSensorsUseCase
    @Injected(\.sensorMeasurementDataFormatter) private var sensorMeasurementDataFormatter
    @Injected(\.networkConnectionMonitorUseCase) private var networkConnectionMonitorUseCase
    
    // MARK: Lifecycle
    
    init(station: Station) {
        self.station = station
        super.init()
        
        isLoading = true
    }
    
    // MARK: Methods
    
    func fetchSensorsForStation() async {
        isLoading(true, objectWillChnage: true)
        
        do {
            try await checkIsInternetConnected()
            
            self.fetchedSensors = try await getSensorsUseCase.getSensors(for: station.id)
            
            let sensors = self.fetchedSensors
                .map {
                    createSensorRow(from: $0)
                }
                .sorted {
                    if $0.lastMeasurementAqi == $1.lastMeasurementAqi {
                        $0.lastMeasurementPercentageValue ?? 0 > $1.lastMeasurementPercentageValue ?? 0
                    } else {
                        $0.lastMeasurementAqi > $1.lastMeasurementAqi
                    }
                }
            
            isLoading(false, objectWillChnage: false)
            self.sensors = sensors
        } catch {
            
            Logger.error("Fetching measurements for sensors with error: \(error)")
            errorSubject.send(error)
        }
    }
    
    nonisolated func refresh() {
        Task { [weak self] in
            await self?.fetchSensorsForStation()
        }
    }
    
    func getSensor(for id: Int) -> Sensor? {
        fetchedSensors.first(where: { $0.id == id })
    }
    
    // MARK: Private methods
    
    private func createSensorRow(from sensor: Sensor) -> SelectedStationModel.SensorRow {
        var lastMeasurementAqi: AQI = .undefined
        var lastMeasurementPercentageValue: Double?
        var lastMeasurementFormattedDate: String = "-"
        var lastMeasurementFormattedValue: String = "-"
        var lastMeasurementFormattedPercentageValue: String = "-"
        
        if let lastMeasurement = sensor.measurements.first(where: { $0.measurement != nil }),
           let lastMeasurementValue = lastMeasurement.measurement {
            lastMeasurementAqi = sensor.param.getAqi(for: lastMeasurementValue.value)
            
            lastMeasurementFormattedValue = measurementValueMeasurementFormatter.string(from: lastMeasurementValue)
            
            let percentageValue = lastMeasurementValue.value / sensor.param.quota
            
            lastMeasurementPercentageValue = percentageValue
            lastMeasurementFormattedPercentageValue = measurementPercentageValueNumberFormatter.string(from: percentageValue) ?? "-"
            
            lastMeasurementFormattedDate = sensorMeasurementDataFormatter.format(date: lastMeasurement.date)
        }
        
        return Model.SensorRow(
            id: sensor.id,
            param: sensor.param,
            lastMeasurementAqi: lastMeasurementAqi,
            lastMeasurementPercentageValue: lastMeasurementPercentageValue,
            lastMeasurementFormattedDate: lastMeasurementFormattedDate,
            lastMeasurementFormattedValue: lastMeasurementFormattedValue,
            lastMeasurementFormattedPercentageValue: lastMeasurementFormattedPercentageValue
        )
    }
}

extension NumberFormatter {
    func string(from number: Double) -> String? {
        string(from: NSNumber(floatLiteral: number)) // swiftlint:disable:this compiler_protocol_init
    }
}
