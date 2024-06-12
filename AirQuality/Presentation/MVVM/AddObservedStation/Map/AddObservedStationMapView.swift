//
//  AddObservedStationMapView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import SwiftUI
import MapKit

struct AddObservedStationMapView: View {
    private typealias L10n = Localizable.AddObservedStationMapView
    
    @StateObject private var viewModel: AddObservedStationMapViewModel
    
    @EnvironmentObject private var coordinator: AddObservedStationMapCoordinator
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            Map {
                ForEach(viewModel.annotations) { stationAnnotation in
                    StationMapAnnotationView(stationAnnotation: stationAnnotation, viewModel: viewModel)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapScaleView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.navigationTitle)
        .dimissToolbarButton {
            coordinator.dismiss()
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddObservedStationMapViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    GetStationsUseCasePreviewDummy.getStationsReturnValue = [
        .previewDummy(id: 1, latitude: 50.057678, longitude: 19.926189),
        .previewDummy(id: 2, latitude: 50.010575, longitude: 19.949189),
        .previewDummy(id: 3, latitude: 50.069308, longitude: 20.053492)
    ]
    
    @ObservedObject var coordinator = AddObservedStationMapCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {})
    )
    
    return TabView {
        NavigationStack {
            AddObservedStationMapView()
                .environmentObject(coordinator)
        }
    }
}
