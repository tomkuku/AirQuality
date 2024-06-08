//
//  AddObservedStationMapView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import SwiftUI
import MapKit

struct AddObservedStationMapView: View {
    @StateObject private var viewModel: AddObservedStationMapViewModel
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    
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
            .taskOnFirstAppear {
                viewModel.fetchStations()
            }
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddObservedStationMapViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
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
