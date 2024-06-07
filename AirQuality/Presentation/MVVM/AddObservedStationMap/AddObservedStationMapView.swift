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
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: @escaping @autoclosure () -> AddObservedStationMapViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel())
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
