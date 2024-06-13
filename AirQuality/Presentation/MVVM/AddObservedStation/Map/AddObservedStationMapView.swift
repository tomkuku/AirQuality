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
    
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var findingTheNearestStation = false
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            ZStack {
                Map(position: $mapCameraPosition) {
                    ForEach(viewModel.annotations) { stationAnnotation in
                        StationMapAnnotationView(
                            stationAnnotation: stationAnnotation,
                            viewModel: viewModel
                        )
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapScaleView()
                }
                
                findTheNearestStationButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(L10n.navigationTitle)
            .onReceive(viewModel.theNearestStationPublisher) { station in
                let stationLocationCoordinate = CLLocationCoordinate2D(
                    latitude: station.latitude,
                    longitude: station.longitude
                )
                
                let coordinateRegion = MKCoordinateRegion(
                    center: stationLocationCoordinate,
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                )
                withAnimation {
                    findingTheNearestStation = false
                    mapCameraPosition = MapCameraPosition.region(coordinateRegion)
                }
            }
            .dimissToolbarButton {
                coordinator.dismiss()
            }
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    private var findTheNearestStationButton: some View {
        VStack {
            Spacer()
            
            Button {
                findingTheNearestStation = true
                viewModel.findTheNearestStation()
            } label: {
                if findingTheNearestStation {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(L10n.findTheNearestStationButton)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 48)
            .disabled(findingTheNearestStation)
            .background(.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddObservedStationMapViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    GetStationsUseCasePreviewDummy.getStationsReturnValue = [
        Station.previewDummy(id: 1, latitude: 50.057678, longitude: 19.926189),
        Station.previewDummy(id: 2, latitude: 50.010575, longitude: 19.949189),
        Station.previewDummy(id: 3, latitude: 50.069308, longitude: 20.053492)
    ]
    
    FindTheNearestStationUseCasePreviewDummy.theNearestStation = (station: Station.previewDummy(latitude: 50.057678, longitude: 19.926189), distance: 20)
    
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
