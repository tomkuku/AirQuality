//
//  SelectedStationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI

struct SelectedStationView: View {
    private typealias L10n = Localizable.SelectedStationView
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @StateObject private var viewModel: SelectedStationViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.sensors) { sensor in
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
                    .gesture(TapGesture().onEnded({ _ in
                        guard let sensor = viewModel.getSensor(for: sensor.id) else {
                            Logger.error("No station for id: \(sensor.id)")
                            return
                        }
                        
                        appCoordinator.goTo(.sensorsDetails(sensor))
                    }))
                    .accessibilityAddTraits(.isButton)
                }
                
                HStack {
                    Text(L10n.dataProvider)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .background(Color.Background.primary)
        .task {
            await viewModel.fetchSensorsForStation()
        }
        .navigationTitle(viewModel.fomattedStationAddress)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(viewModel: @autoclosure @escaping () -> SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
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

#Preview {
    GetSensorsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, param: .pm10),
        .previewDummy(id: 2, param: .pm25),
        .previewDummy(id: 3, param: .c6h6),
        .previewDummy(id: 4, param: .co),
        .previewDummy(id: 5, param: .no2),
        .previewDummy(id: 6, param: .o3),
        .previewDummy(id: 7, param: .so2)
    ]
    
    let station = Station.previewDummy()
    
    return NavigationStack {
        SelectedStationView(viewModel: .init(station: station))
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GetSensorsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, param: .pm10),
        .previewDummy(id: 2, param: .pm25),
        .previewDummy(id: 3, param: .c6h6),
        .previewDummy(id: 4, param: .co),
        .previewDummy(id: 5, param: .no2),
        .previewDummy(id: 6, param: .o3),
        .previewDummy(id: 7, param: .so2)
    ]
    
    let station = Station.previewDummy()
    
    return NavigationStack {
        SelectedStationView(viewModel: .init(station: station))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
    }
}

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
