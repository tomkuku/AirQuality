//
//  AddObservedStationMapView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import SwiftUI
import MapKit

struct AddObservedStationMapView: View {
    @ObservedObject private var viewModel: AddObservedStationMapViewModel
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    
    var body: some View {
        Map {
            ForEach(viewModel.annotations) { stationAnnotation in
                StationMapAnnotationView(stationAnnotation: stationAnnotation, viewModel: viewModel)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapScaleView()
        }
        .onReceive(viewModel.toastPublisher) { toast in
            coordinator.showToast(toast)
        }
        .onReceive(viewModel.errorPublisher) { _ in
            coordinator.showAlert(.somethigWentWrong())
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: AddObservedStationMapViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
}

#Preview {
    let viewModel = AddObservedStationMapViewModel()
    
    return NavigationStack {
        AddObservedStationMapView(viewModel: viewModel)
            .navigationTitle("Title")
            .navigationBarTitleDisplayMode(.inline)
    }
}
