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
    @State private var selectedMapStyle: MapStyle = .standard
    @State private var showUserLocation: Bool = false
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) { error in
            handleError(error)
        } contentView: {
            ZStack {
                Map(position: $mapCameraPosition) {
                    ForEach(viewModel.annotations) { stationAnnotation in
                        StationMapAnnotationView(stationAnnotation: stationAnnotation)
                    }
                    
                    if let userLocation = viewModel.userLocation, showUserLocation {
                        Annotation("", coordinate: userLocation.coordinate) {
                            Image.circleCircleFill
                        }
                    }
                }
                .mapStyle(selectedMapStyle.mapStyle)
                
                BottomSheet(minHeight: 50, maxHeight: 250) {
                    bottomMenu
                        .background(Color.Background.secondary)
                }
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
        .onReceive(viewModel.deletedObservedStationPublisher) { _ in
            coordinator.showToast(.observedStationWasDeleted())
        }
        .onReceive(viewModel.addedObservedStationPublisher) { _ in
            coordinator.showToast(.observedStationWasAdded())
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    private var findTheNearestStationButton: some View {
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
    }
    
    private var bottomMenu: some View {
        List {
            Group {
                Section {
                    Toggle(isOn: $showUserLocation) {
                        Text(L10n.BottomMenu.showUserLocation)
                    }
                    
                    Picker(L10n.BottomMenu.MapStyle.buttonTitle, selection: $selectedMapStyle) {
                        Text(MapStyle.hybrid.text).tag(MapStyle.hybrid)
                        Text(MapStyle.standard.text).tag(MapStyle.standard)
                    }
                    .pickerStyle(.menu)
                }
                
                findTheNearestStationButton
                    .listRowSeparator(.hidden)
            }
            .listRowBackground(Color.Background.secondary)
        }
        .listStyle(.plain)
        .background(Color.Background.secondary)
        .scrollDisabled(true)
        .padding(.top, 16)
        .onChange(of: showUserLocation) {
            if showUserLocation {
                viewModel.startTrackingUserLocation()
            } else {
                viewModel.stopTrackingUserLocation()
            }
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddObservedStationMapViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
    
    private func handleError(_ error: Error) {
        if let viewModelError = error as? AddObservedStationMapModel.ErrorType {
            switch viewModelError {
            case .findingTheNearestStationsFailed:
                coordinator.showAlert(.findingTheNearestStationsFailed())
            }
        }
        
        if let locationServicesError = error as? UserLocationServicesError {
            switch locationServicesError {
            case .disabled:
                coordinator.showAlert(.locationServicesDisabled(coordinator))
            case .authorizationRestricted:
                coordinator.showAlert(.locationServicesAuthorizationRestricted(coordinator))
            case .authorizationDenied:
                coordinator.showAlert(.locationServicesAuthorizationDenied(coordinator))
            }
        }
        
        coordinator.showAlert(.somethigWentWrong())
    }
}

// MARK: MapStyle

private extension AddObservedStationMapView {
    enum MapStyle: Hashable {
        case hybrid
        case standard
        
        var text: String {
            switch self {
            case .hybrid:
                Localizable.AddObservedStationMapView.BottomMenu.MapStyle.satellite
            case .standard:
                Localizable.AddObservedStationMapView.BottomMenu.MapStyle.standard
            }
        }
        
        var mapStyle: MapKit.MapStyle {
            switch self {
            case .hybrid:
                MapKit.MapStyle.hybrid
            case .standard:
                MapKit.MapStyle.standard
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(text)
        }
    }
}

// MARK: Preview

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        Station.previewDummy(id: 1, latitude: 50.057678, longitude: 19.926189),
        Station.previewDummy(id: 2, latitude: 50.010575, longitude: 19.949189),
        Station.previewDummy(id: 3, latitude: 50.069308, longitude: 20.053492)
    ]
    
    FindTheNearestStationUseCasePreviewDummy.theNearestStation = (station: Station.previewDummy(latitude: 50.057678, longitude: 19.926189), distance: 20)
    
    GetUserLocationUseCasePreviewDummy.locationStreamLocationRange = (
        latitudeRange: 49.99641122048959...50.108355664132304,
        longitudeRange: 19.809025813548537...20.07418371676789
    )
    
    GetUserLocationUseCasePreviewDummy.checkLocationServicesAvailabilityError = .authorizationDenied
    
    @ObservedObject var coordinator = AddObservedStationMapCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {})
    )
    
    return TabView {
        NavigationStack {
            AddObservedStationMapView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark)
        }
    }
}
