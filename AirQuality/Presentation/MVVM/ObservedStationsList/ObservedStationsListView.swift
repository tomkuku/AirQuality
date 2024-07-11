//
//  ObservedStationsListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import SwiftUI

struct ObservedStationsListView: View {
    
    private typealias L10n = Localizable.ObservedStationsListView
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel: ObservedStationsListViewModel
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            if viewModel.stations.isEmpty {
                Spacer()
                
                Text(L10n.noObservedStations)
                
                Spacer()
            } else {
                List {
                    ForEach(viewModel.stations) { station in
                        createStationRow(station)
                            .frame(maxWidth: .infinity)
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .safeAreaInset(edge: .bottom) {
            addObservedStationsButton
                .frame(height: 50)
        }
        .navigationTitle(L10n.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var addObservedStationsButton: some View {
        VStack {
            Spacer()
            
            Button {
                coordinator.goTo(.addNewObservedStation)
            } label: {
                Text(L10n.addStation)
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .black.opacity(0.3), radius: 16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    init(viewModel: @autoclosure @escaping () -> ObservedStationsListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
    
    private func createStationRow(_ station: Station) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(station.street ?? "")
                
                Text(station.cityName)
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            Spacer()
        }
        .background(.clear)
        .accessibility(addTraits: [.isButton])
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded {
            coordinator.goTo(.slectedStation(station))
        })
        .swipeActions {
            Button(L10n.delete, role: .destructive) {
                viewModel.deletedObservedStation(station)
            }
        }
    }
}

#Preview {
    let appCoordinator = AppCoordinator(coordinatorNavigationType: .presentation(dismissHandler: {}))
    
    GetObservedStationsUseCasePreviewDummy.createNewStreamStations = .success([
        .previewDummy(id: 1, street: "al. Krasińskiego"),
        .previewDummy(id: 2, street: "ul. Bujaka"),
        .previewDummy(id: 3, street: "ul. Bulwarowa"),
        .previewDummy(id: 4, street: "ul. Bulwarowa"),
        .previewDummy(id: 5, street: "ul. Kamieńskiego"),
        .previewDummy(id: 6, street: "os. Piastów"),
        .previewDummy(id: 7, cityName: "Tarnów", street: "ul. Bitwy pod Studziankami"),
        .previewDummy(id: 8, cityName: "Tarnów", street: "ul. Ks. Romana Sitko")
    ])
    
    return NavigationStack {
        ObservedStationsListView()
            .environmentObject(appCoordinator)
            .navigationTitle(Localizable.ObservedStationsListView.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
