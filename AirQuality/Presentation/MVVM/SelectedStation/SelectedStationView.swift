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
                    let lastMeasurement = viewModel.formatLastMeasurement(for: sensor)
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
                            
                            createLastMeasurementView(for: lastMeasurement)
                        }
                        .background(sensor.param.getAqi(for: lastMeasurement.measurement?.value).color)
                        .cornerRadius(10)
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
}

#Preview {
    NavigationStack {
        SelectedStationView(viewModel: .previewDummy)
            .navigationBarTitleDisplayMode(.inline)
    }
}
