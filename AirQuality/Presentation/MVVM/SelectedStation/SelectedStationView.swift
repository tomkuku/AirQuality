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
                        let precentValueOfLastMeasurement = sensor.precentValueOfLastMeasurement
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sensor.param.code)
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Nazwa")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.7))
                                
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
        if let measurement = sensor.measurements.last {
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(sensor.precentValueOfLastMeasurement)%")
                    .font(.system(size: 18, weight: .bold))
                
                Text("\(String(format: "%.2f", measurement.value ?? 0.0)) µg/m³")
                    .font(.system(size: 12, weight: .semibold))
                
                Text("data")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.7))
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
        } else {
            Rectangle()
                .foregroundStyle(Color.clear)
        }
    }
}

#Preview {
    NavigationStack {
        SelectedStationView(viewModel: .previewDummy)
            .navigationBarTitleDisplayMode(.inline)
    }
}
