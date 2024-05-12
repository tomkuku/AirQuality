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
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sensor.formula)
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(sensor.name)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.7))
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            
                            Spacer()
                        }
                        .background(Color.white)
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
    }
    
    init(viewModel: SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    NavigationStack {
        SelectedStationView(viewModel: .previewDummy)
            .navigationBarTitleDisplayMode(.inline)
    }
}
