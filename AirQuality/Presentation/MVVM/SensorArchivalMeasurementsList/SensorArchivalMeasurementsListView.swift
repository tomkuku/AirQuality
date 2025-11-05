//
//  SensorArchivalMeasurementsListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import SwiftUI

struct SensorArchivalMeasurementsListView<UseCase>: View where UseCase: FetchArchivalMeasurementsUseCaseProtocol {
    
    typealias ViewModel = SensorArchivalMeasurementsListViewModel<UseCase>
    
    // MARK: Properties
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            if !viewModel.isLoading {
                ScrollView {
                    PaginationFetchingView(viewModel: viewModel) { section in
                        Section {
                            ForEach(section.rows) { row in
                                HStack {
                                    Text("\(row.formattedDate)")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 8) {
                                        Text("\(row.formattedValue) µg/m³")
                                            .font(.system(size: 18, weight: .medium))
                                    }
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                            }
                        } header: {
                            HStack {
                                Text("\(section.name)")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Spacer()
                            }
                            .padding(.leading, 16)
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                        .controlSize(.regular)
                    
                    Text(Localizable.SelectedStationView.isLoading)
                }
            }
        }
        .navigationTitle(viewModel.sensor.param.formula)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.goTo(.archivalMeasurementsOptions(
                        viewModel.options,
                        callback: { options in
                            viewModel.setOptions(options)
                        }))
                } label: {
                    Image.line3HorizontalDecreaseCircle
                        .renderingMode(.template)
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .taskOnFirstAppear {
            viewModel.fetchTheFirstPage()
        }
    }
    
    // MARK: Private properties
    
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: Lifecycle
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

// MARK: Preview

#Preview {
    let sensor = Sensor.previewDummy()
    let useCase = FetchArchivalMeasurementsUseCasePreviewDummy()
    let viewModel = SensorArchivalMeasurementsListViewModel<FetchArchivalMeasurementsUseCasePreviewDummy>(sensor: sensor, useCase: useCase)
    let appCoordinator = AppCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {}),
        alertSubject: .init(),
        toastSubject: .init()
    )
    
    NavigationStack {
        SensorArchivalMeasurementsListView(viewModel: viewModel)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(appCoordinator)
    }
}
