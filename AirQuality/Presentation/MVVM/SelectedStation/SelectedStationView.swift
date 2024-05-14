//
//  SelectedStationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI

struct SelectedStationView: View {
    @StateObject private var viewModel: SelectedStationViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.sensors) { sensor in
                    if let lastMeasurement = sensor.measurements.last {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sensor.param.formula)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text(sensor.param.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color.black)
                                
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            
                            Spacer()
                            
                            createSensorRowView(for: sensor)
                        }
                        .background(sensor.param.getAqi(for: lastMeasurement.value ?? 0.0).color)
                        .cornerRadius(10)
                    } else {
                        EmptyView()
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .background(Color.gray.opacity(0.6))
        .task {
            await viewModel.fetchSensorsForStation()
        }
        .navigationTitle(viewModel.fomattedStationAddress)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(viewModel: SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @ViewBuilder
    func createSensorRowView(for sensor: Sensor) -> some View {
        let lastMeasurement = sensor.formattedLastMeasurement
        VStack(alignment: .trailing, spacing: 8) {
            Text("\(lastMeasurement.percentageValue)%")
                .font(.system(size: 18, weight: .bold))
            
            Text("\(lastMeasurement.value) µg/m³")
                .font(.system(size: 12, weight: .semibold))
            
            Text(lastMeasurement.date)
                .font(.system(size: 12, weight: .regular))
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
    }
}

#Preview {
    NavigationStack {
        SelectedStationView(viewModel: .previewDummy)
            .navigationBarTitleDisplayMode(.inline)
    }
}
