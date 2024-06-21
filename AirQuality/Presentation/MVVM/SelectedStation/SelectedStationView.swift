//
//  SelectedStationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI

struct SelectedStationView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @StateObject private var viewModel: SelectedStationViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(0..<viewModel.sensors.count, id: \.self) { index in
                    let sensor = viewModel.sensors[index]
                    let value = sensor.lastMeasurement.measurement?.value
                    let aqi = sensor.domainModel.param.getAqi(for: value)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sensor.domainModel.param.formula)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text(sensor.domainModel.param.name)
                                .font(.system(size: 14, weight: .regular))
                            
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        
                        Spacer()
                        
                        createLastMeasurementView(for: sensor.lastMeasurement)
                    }
                    .foregroundStyle(getForegroundColor(for: aqi))
                    .background(sensor.domainModel.param.getAqi(for: sensor.lastMeasurement.measurement?.value).color)
                    .cornerRadius(10)
                    .gesture(TapGesture().onEnded({ _ in
                        appCoordinator.goTo(.sensorsDetails(sensor.domainModel))
                    }))
                    .accessibilityAddTraits(.isButton)
                }
                
                HStack {
                    Text("Dostawcą danych jest Główny Inspektorat Ochrony Środowiska")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
        .task {
            await viewModel.fetchSensorsForStation()
        }
        .navigationTitle(viewModel.fomattedStationAddress)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(viewModel: @autoclosure @escaping () -> SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
    
    @ViewBuilder
    func createLastMeasurementView(for lastMeasurement: SelectedStationModel.LastMeasurement) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(lastMeasurement.formattedPercentageValue + "%")
                .font(.system(size: 18, weight: .bold))
            
            Text(lastMeasurement.formattedValue + " µg/m³")
                .font(.system(size: 12, weight: .semibold))
            
            Text(lastMeasurement.formattedDate)
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
