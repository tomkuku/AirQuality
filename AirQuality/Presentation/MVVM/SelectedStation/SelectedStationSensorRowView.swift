//
//  SelectedStationSensorRowView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/09/2024.
//

import SwiftUI

struct SelectedStationSensorRow: View {
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                createFormulaText(sensor.param)
                
                Text(sensor.param.name)
                    .font(.system(size: 14, weight: .regular))
                
                Spacer()
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            Spacer()
            
            createSensorView(for: sensor)
        }
        .foregroundStyle(getForegroundColor(for: sensor.lastMeasurementAqi))
        .background(sensor.lastMeasurementAqi.color)
        .cornerRadius(10)
        .accessibilityAddTraits(.isButton)
        .opacity(animated ? 1 : 0)
        .offset(y: offset)
        .zIndex(Double(-index))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 3)
        .gesture(TapGesture().onEnded({ _ in
//            guard let sensor = viewModel.getSensor(for: sensor.id) else {
//                Logger.error("No station for id: \(sensor.id)")
//                return
//            }
//
//            appCoordinator.goTo(.sensorsDetails(sensor))
        }))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).delay(TimeInterval(index) * 0.2)) {
                animated = true
            }
        }
    }
    
    func createSensorView(for sensorRow: SelectedStationModel.SensorRow) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(sensorRow.lastMeasurementFormattedPercentageValue)
                .font(.system(size: 18, weight: .bold))
            
            Text(sensorRow.lastMeasurementFormattedValue)
                .font(.system(size: 12, weight: .semibold))
            
            Text(sensorRow.lastMeasurementFormattedDate)
                .font(.system(size: 12, weight: .regular))
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
    }
    
    // MARK: Private properties
    
    @State private var animated = false
    
    private var offset: CGFloat {
        if animated {
            0
        } else if index == 0 {
            0
        } else {
            -100
        }
    }
    
    private let sensor: SelectedStationModel.SensorRow
    private let index: Int
    
    // MARK: Lifecycle
    
    init(sensor: SelectedStationModel.SensorRow, index: Int) {
        self.sensor = sensor
        self.index = index
    }
    
    // MARK: Private methods
    
    private func getForegroundColor(for aqi: AQI) -> Color {
        switch aqi {
        case .good, .unhealthy, .unhealthyForSensitiveGroup, .veryUnhealthy, .hazardus:
            Color.white
        case .moderate, .undefined:
            Color.black
        }
    }
    
    @ViewBuilder
    private func createFormulaText(_ param: Param) -> some View {
        if param.formulaNumbersInBottomBaseline {
            let characters: [String] = param.formula.map { String($0) }
            
            HStack(spacing: 0) {
                ForEach(characters, id: \.self) { character in
                    if character.isNumber {
                        Text(character)
                            .baselineOffset(-10)
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        Text(character)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
        } else {
            Text(param.formula)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

// MARK: Preview

#Preview {
    let rowModel = SelectedStationModel.SensorRow(
        id: 111,
        param: .c6h6,
        lastMeasurementAqi: .good,
        lastMeasurementPercentageValue: 0.8,
        lastMeasurementFormattedDate: "Jun 25, 2024 at 14:00",
        lastMeasurementFormattedValue: "4 µg/m³",
        lastMeasurementFormattedPercentageValue: "80%"
    )
    
    return SelectedStationSensorRow(sensor: rowModel, index: 0)
        .frame(width: .infinity, height: 100)
}
