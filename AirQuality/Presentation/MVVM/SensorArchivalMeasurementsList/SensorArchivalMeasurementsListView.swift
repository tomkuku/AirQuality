//
//  SensorArchivalMeasurementsListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import SwiftUI

struct SensorArchivalMeasurementsListView: View {
    
    @StateObject private var viewModel: SensorArchivalMeasurementsListViewModel
    
    var body: some View {
        BaseView(isLoading: Binding(projectedValue: .constant(viewModel.idLoading))) {
            ScrollView {
                ForEach(0..<viewModel.rows.count, id: \.self) { index in
                    let row = viewModel.rows[index]
                    
                    HStack {
                        Text(row.formattedDate)
                            .font(.system(size: 16, weight: .regular))
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("\(row.formattedPercentageValue)%")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("\(row.formattedValue) µg/m³")
                                .font(.system(size: 16, weight: .regular))
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    
                    if index < viewModel.rows.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .taskOnFirstAppear {
            await viewModel.fetchArchivalMeasurements()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> SensorArchivalMeasurementsListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    let viewModel = SensorArchivalMeasurementsListViewModel.previewDummy
    return SensorArchivalMeasurementsListView(viewModel: viewModel)
}

struct BaseView<T>: View where T: View {
    
    @Binding private var isLoading: Bool
    
    private var contentView: T
    
    var body: some View {
        VStack {
            if isLoading {
                HStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    Spacer()
                }
            } else {
                contentView
            }
        }
    }
    
    init(
        isLoading: Binding<Bool>,
        contentView: @escaping () -> T
    ) {
        self._isLoading = isLoading
        self.contentView = contentView()
    }
}
